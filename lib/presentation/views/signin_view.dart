import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/core/services/secure_storage_service.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/widgets/auth/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/auth/social_login_button.dart';
import 'package:manzili_mobile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  /// Client-side validation only (server errors come from [AuthProvider.errorMessage]).
  String? _validationHint;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the checkbox with the user's last saved preference.
    SecureStorageService.readRememberMe().then((value) {
      if (mounted) setState(() => _rememberMe = value);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() {
        _validationHint = AppLocalizations.of(context)!.errEmailOrPhoneEmpty;
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _validationHint = AppLocalizations.of(context)!.errInvalidCredentials;
      });
      return;
    }
    setState(() => _validationHint = null);

    final success = await auth.login(
      email: email,
      password: password,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (success) {
      // Defer so router + listeners settle (avoids rare no-op navigation).
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.go(auth.postLoginRoute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // ── Gradient top area (~40% of screen) ──────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.42,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF2A1A14), const Color(0xFF1A1A1A)]
                        : [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'منزلي',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'أهلاً بيك، سجّل دخولك',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── White card sliding up from bottom ────────────────────────
            Positioned(
              top: size.height * 0.35,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    keyboardHeight + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Email field ──────────────────────────────────
                      CustomTextField(
                        label: AppLocalizations.of(context)!.fieldEmailOrPhone,
                        hint: AppLocalizations.of(context)!.fieldEmailOrPhoneHint,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                      ),
                      const Gap(16),

                      // ── Password field ───────────────────────────────
                      CustomTextField(
                        label: AppLocalizations.of(context)!.fieldPassword,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 22,
                            color: AppColors.textHint,
                          ),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                      ),
                      const Gap(12),

                      // ── Remember me + Forgot password ────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  activeColor: AppColors.accent,
                                  side: const BorderSide(
                                    color: AppColors.accent,
                                    width: 1.4,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context)!.rememberMe,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Gap(24),

                      // ── Validation / server errors ───────────────────
                      Selector<AuthProvider, String?>(
                        selector: (_, a) => a.errorMessage,
                        builder: (context, err, _) {
                          final msg = _validationHint ?? err;
                          if (msg == null || msg.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              msg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),

                      // ── Primary CTA ──────────────────────────────────
                      Selector<AuthProvider, AuthStatus>(
                        selector: (context, auth) => auth.status,
                        builder: (context, status, _) {
                          final isLoading =
                              status == AuthStatus.authenticating;
                          return FilledButton(
                            onPressed: isLoading
                                ? null
                                : () => _handleLogin(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.signInCta,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          );
                        },
                      ),
                      const Gap(12),

                      // ── No account link ──────────────────────────────
                      Center(
                        child: Selector<AuthProvider, AuthStatus>(
                          selector: (_, a) => a.status,
                          builder: (context, status, _) {
                            final isLoading =
                                status == AuthStatus.authenticating;
                            return TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.push('/signup'),
                              child: Text(
                                AppLocalizations.of(context)!.noAccountSignUp,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Gap(24),

                      // ── Divider ──────────────────────────────────────
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              AppLocalizations.of(context)!.socialLoginOr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const Gap(16),

                      // ── Social login buttons ─────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialLoginButton(
                            onTap: () async {
                              final success = await context
                                  .read<AuthProvider>()
                                  .loginWithGoogle();
                              if (success && context.mounted) {
                                context.go(context
                                    .read<AuthProvider>()
                                    .postLoginRoute);
                              }
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.google,
                              size: 28,
                              color: Color(0xFFDB4437),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SocialLoginButton(
                            onTap: () async {
                              final success = await context
                                  .read<AuthProvider>()
                                  .loginWithFacebook();
                              if (success && context.mounted) {
                                context.go(context
                                    .read<AuthProvider>()
                                    .postLoginRoute);
                              }
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.facebookF,
                              size: 28,
                              color: Color(0xFF4267B2),
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                    ].animate(interval: 50.ms).fade(duration: 500.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
