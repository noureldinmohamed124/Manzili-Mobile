import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/widgets/auth/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/auth/login_row_cta.dart';
import 'package:manzili_mobile/presentation/widgets/auth/social_login_button.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _validationHint = 'اكتب الإيميل والباسورد الأول';
      });
      return;
    }
    setState(() => _validationHint = null);

    final success = await auth.login(
      email: email,
      password: password,
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery.of(context).size;
          final gradientHeight = ResponsiveHelper.scaleValue(
            67.5, // 18% of 375 base
            constraints.maxHeight,
            min: constraints.maxHeight * 0.12,
            max: constraints.maxHeight * 0.20,
          );
          final gradientBottomHeight = ResponsiveHelper.scaleValue(
            75.0, // 20% of 375 base
            size.height,
            min: size.height * 0.18,
            max: size.height * 0.20,
          );
          final gradientBottomWidth = ResponsiveHelper.scaleValue(
            75.0, // 20% of 375 base
            size.width,
            min: size.width * 0.20,
            max: size.width * 0.25,
          );
          final viewInsets = MediaQuery.of(context).viewInsets;
          final keyboardHeight = viewInsets.bottom;

          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: _TopWaveClipper(),
                      child: Container(
                        height: gradientHeight,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.authGradientStart, AppColors.authGradientEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                  children: [
                    Gap(gradientHeight + ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 16.0)),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(ResponsiveHelper.responsiveValueFromConstraints(constraints, base: 40.0, lg: 44.0)),
                          ),
                        ),
                        child: ResponsiveMaxWidth(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              top: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 20.0),
                              bottom: keyboardHeight + ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 20.0),
                            ),
                            child: Column(
                              children: [
                                Text(
                                    'مرحباً',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.responsiveFontSize(context, base: 38.0, min: 28.0, max: 48.0),
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).textTheme.displayLarge?.color ?? AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 6.0)),
                                  Text(
                                    'سجل الدخول إلى حسابك',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.responsiveFontSize(context, base: 15.0, min: 13.0, max: 17.0),
                                      color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 24.0)),
                                  // No role picker: role is determined by backend token (buyer/seller/admin).
                                  CustomTextField(
                                    label: 'البريد الالكتروني',
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 18.0)),
                                  CustomTextField(
                                    label: 'كلمة المرور',
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: ResponsiveHelper.scaleValue(22.0, constraints.maxWidth, min: 20.0, max: 24.0),
                                        color: AppColors.textHint,
                                      ),
                                      onPressed: () => setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      }),
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 16.0)),
                                  LayoutBuilder(
                                    builder: (context, rowConstraints) {
                                      if (rowConstraints.maxWidth < 300) {
                                        // Very narrow: stack vertically
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextButton(
                                              onPressed: () {},
                                              child: Text(
                                                AppStrings.forgotPassword,
                                                style: TextStyle(
                                                  fontSize: ResponsiveHelper.responsiveFontSize(context, base: 13.0, min: 11.0, max: 15.0),
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Checkbox(
                                                  value: _rememberMe,
                                                  onChanged: (v) => setState(
                                                      () => _rememberMe = v ?? false),
                                                  activeColor: AppColors.accent,
                                                  side: const BorderSide(
                                                    color: AppColors.accent,
                                                    width: 1.4,
                                                  ),
                                                ),
                                                Text(
                                                  AppStrings.rememberMe,
                                                  style: TextStyle(
                                                    fontSize: ResponsiveHelper.responsiveFontSize(context, base: 13.0, min: 11.0, max: 15.0),
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }
                                      
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () {},
                                            child: Text(
                                              AppStrings.forgotPassword,
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.responsiveFontSize(context, base: 13.0, min: 11.0, max: 15.0),
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Checkbox(
                                                  value: _rememberMe,
                                                  onChanged: (v) => setState(
                                                      () => _rememberMe = v ?? false),
                                                  activeColor: AppColors.accent,
                                                  side: const BorderSide(
                                                    color: AppColors.accent,
                                                    width: 1.4,
                                                  ),
                                                ),
                                                Text(
                                                  AppStrings.rememberMe,
                                                  style: TextStyle(
                                                    fontSize: ResponsiveHelper.responsiveFontSize(context, base: 13.0, min: 11.0, max: 15.0),
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 24.0)),
                                  Selector<AuthProvider, AuthStatus>(
                                    selector: (context, auth) => auth.status,
                                    builder: (context, status, _) {
                                      final isLoading = status == AuthStatus.authenticating;

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: LoginRowCTA(
                                                text: isLoading
                                                    ? AppStrings.signInLoading
                                                    : AppStrings.signInCta,
                                                onTap: isLoading
                                                    ? null
                                                    : () => _handleLogin(context),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: ResponsiveHelper.responsiveSpacingFromConstraints(
                                              constraints,
                                              base: 10.0,
                                            ),
                                          ),
                                          if (_validationHint != null)
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: Text(
                                                _validationHint!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: AppColors.error,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          Selector<AuthProvider, String?>(
                                            selector: (_, a) => a.errorMessage,
                                            builder: (context, err, _) {
                                              if (err == null || err.isEmpty) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Text(
                                                  err,
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
                                          Center(
                                            child: TextButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () {
                                                      context.push('/signup');
                                                    },
                                              child: const Text(
                                                AppStrings.noAccountSignUp,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.accent,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 30.0)),
                                  LayoutBuilder(
                                    builder: (context, dividerConstraints) {
                                      if (dividerConstraints.maxWidth < 300) {
                                        // Very narrow: stack divider and text
                                        return Column(
                                          children: [
                                            const Divider(),
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 8.0)),
                                              child: Text(
                                                'أو سجل باستخدام وسائل التواصل الاجتماعي',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: ResponsiveHelper.responsiveFontSize(context, base: 12.0, min: 10.0, max: 14.0),
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            const Divider(),
                                          ],
                                        );
                                      }
                                      
                                      return Row(
                                        children: [
                                          const Expanded(child: Divider()),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 12.0)),
                                            child: Text(
                                              'أو سجل باستخدام وسائل التواصل الاجتماعي',
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.responsiveFontSize(context, base: 12.0, min: 10.0, max: 14.0),
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          const Expanded(child: Divider()),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 16.0)),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 14.0),
                                    children: [
                                      SocialLoginButton(
                                        child: const FaIcon(FontAwesomeIcons.google, size: 30, color: Color(0xFFDB4437)),
                                        onTap: () async {
                                          final success = await context.read<AuthProvider>().loginWithGoogle();
                                          if (success && context.mounted) {
                                            context.go(context.read<AuthProvider>().postLoginRoute);
                                          }
                                        },
                                      ),
                                      SocialLoginButton(
                                        child: const FaIcon(FontAwesomeIcons.facebookF, size: 30, color: Color(0xFF4267B2)),
                                        onTap: () async {
                                          final success = await context.read<AuthProvider>().loginWithFacebook();
                                          if (success && context.mounted) {
                                            context.go(context.read<AuthProvider>().postLoginRoute);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Gap(ResponsiveHelper.responsiveSpacingFromConstraints(constraints, base: 26.0)),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: 'ليس لديك حساب؟ ',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.responsiveFontSize(context, base: 14.0, min: 12.0, max: 16.0),
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'إنشاء حساب',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.white 
                                                : AppColors.accent,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              context.push('/signup');
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ].animate(interval: 50.ms).fade(duration: 500.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5, size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.7,
      size.width, size.height * 0.9,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.25, 0,
      size.width * 0.5, size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.3,
      size.width, size.height * 0.1,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
