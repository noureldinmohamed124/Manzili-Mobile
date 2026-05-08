import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/widgets/auth/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/auth/role_button.dart';
import 'package:manzili_mobile/presentation/widgets/auth/social_login_button.dart';
import 'package:manzili_mobile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/strings/app_strings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  bool _obscurePassword = true;
  String _selectedRole = 'buyer';
  String? _validationHint;
  bool _agreeToTerms = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  int _selectedRoleCode() {
    switch (_selectedRole) {
      case 'buyer':
        return 1;
      case 'seller':
        return 2;
      default:
        return 1;
    }
  }

  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#\$&*~%]').hasMatch(password)) return false;
    return true;
  }

  Future<void> _handleRegister(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _validationHint = AppLocalizations.of(context)!.fillAllFields;
      });
      return;
    }

    if (!_isPasswordValid(password)) {
      setState(() {
        _validationHint = AppLocalizations.of(context)!.errPasswordRequirement;
      });
      return;
    }

    if (!_agreeToTerms) {
      setState(() {
        _validationHint = AppLocalizations.of(context)!.errTermsRequired;
      });
      return;
    }

    setState(() => _validationHint = null);

    final success = await auth.register(
      fullName: fullName,
      email: email,
      password: password,
      role: _selectedRoleCode(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/signin');
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
            // ── Gradient top area ────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.38,
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
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'انضم لمنزلي دلوقتي',
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

            // ── White card ───────────────────────────────────────────────
            Positioned(
              top: size.height * 0.31,
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
                      // ── Role selector ────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: RoleButton(
                              label: AppLocalizations.of(context)!.roleBuyer,
                              icon: Icons.shopping_cart_outlined,
                              isSelected: _selectedRole == 'buyer',
                              onTap: () =>
                                  setState(() => _selectedRole = 'buyer'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RoleButton(
                              label: AppLocalizations.of(context)!.roleSeller,
                              icon: Icons.shopping_bag_outlined,
                              isSelected: _selectedRole == 'seller',
                              onTap: () =>
                                  setState(() => _selectedRole = 'seller'),
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),

                      // ── Name field ───────────────────────────────────
                      CustomTextField(
                        label: AppLocalizations.of(context)!.fieldFullName,
                        controller: _fullNameController,
                      ),
                      const Gap(16),

                      // ── Email field ──────────────────────────────────
                      CustomTextField(
                        label: AppLocalizations.of(context)!.fieldEmail,
                        hint: AppLocalizations.of(context)!.fieldEmailHint,
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
                      const Gap(8),

                      // ── Password hint ────────────────────────────────
                      Text(
                        AppLocalizations.of(context)!.passwordRequirements,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      const Gap(16),

                      // ── Terms checkbox ───────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreeToTerms,
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onChanged: (val) {
                                setState(() {
                                  _agreeToTerms = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.agreeToTerms,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(24),

                      // ── Validation / server errors ───────────────────
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          final msg = _validationHint ?? auth.errorMessage;
                          if (msg == null || msg.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              msg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          );
                        },
                      ),

                      // ── Primary CTA ──────────────────────────────────
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          final isLoading = auth.status == AuthStatus.authenticating;
                          return FilledButton(
                            onPressed: isLoading
                                ? null
                                : () => _handleRegister(context),
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
                                : const Text(
                                    AppStrings.signUpCta,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          );
                        },
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
                              AppStrings.signupSocialDivider,
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
                      const Gap(20),

                      // ── Has account link ─────────────────────────────
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: AppStrings.signupHasAccountPrefix,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodySmall?.color ??
                                AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: AppStrings.signupSignInLink,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.accent,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.go('/signin');
                                },
                            ),
                          ],
                        ),
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
