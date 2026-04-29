import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:manzili_mobile/presentation/providers/auth_provider.dart';
import 'package:manzili_mobile/presentation/widgets/auth/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/auth/login_row_cta.dart';
import 'package:manzili_mobile/presentation/widgets/auth/role_button.dart';
import 'package:manzili_mobile/presentation/widgets/auth/social_login_button.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/strings/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';
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
  String _selectedRole = 'seller';
  String? _validationHint;

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
      default:
        return 2;
    }
  }

  Future<void> _handleRegister(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _validationHint = 'كمّل كل الحقول الأول';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery.of(context).size;
          final gradientHeight = ResponsiveHelper.scaleValue(
            67.5, // 18% of 375 base
            constraints.maxHeight,
            min: constraints.maxHeight * 0.15,
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
                      Gap(gradientHeight + ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 40.0, tablet: 44.0)),
                            ),
                          ),
                          child: ResponsiveMaxWidth(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                top: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 20),
                                bottom: keyboardHeight + ResponsiveHelper.responsiveSpacingCompat(context, mobile: 20),
                              ),
                              child: Column(
                                  children: [
                                  Text(
                                    AppStrings.signupScreenTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 38, tablet: 42, desktop: 46),
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).textTheme.displayLarge?.color ?? AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RoleButton(
                                        label: 'مشتري',
                                        icon: Icons.shopping_cart_outlined,
                                        isSelected: _selectedRole == 'buyer',
                                        onTap: () =>
                                            setState(() => _selectedRole = 'buyer'),
                                      ),
                                    ),
                                    SizedBox(width: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                                    Expanded(
                                      child: RoleButton(
                                        label: 'بائع',
                                        icon: Icons.shopping_bag_outlined,
                                        isSelected: _selectedRole == 'seller',
                                        onTap: () =>
                                            setState(() => _selectedRole = 'seller'),
                                      ),
                                    ),
                                  ],
                                ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 26)),
                                  CustomTextField(
                                    label: 'الاسم بالكامل',
                                    controller: _fullNameController,
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 18)),
                                  CustomTextField(
                                    label: 'البريد الاكتروني',
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 18)),
                                  CustomTextField(
                                    label: 'كلمه المرور',
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: ResponsiveHelper.responsiveValueCompat(context, mobile: 22.0),
                                        color: AppColors.textHint,
                                      ),
                                      onPressed: () => setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      }),
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 24)),
                                  Consumer<AuthProvider>(
                                    builder: (context, auth, _) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: LoginRowCTA(
                                                text: AppStrings.signUpCta,
                                                onTap: () => _handleRegister(context),
                                              ),
                                            ),
                                          ),
                                          if (_validationHint != null) ...[
                                            SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                                            Text(
                                              _validationHint!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 13),
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ],
                                          if (auth.errorMessage != null) ...[
                                            SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                                            Text(
                                              auth.errorMessage!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 13),
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 30)),
                                  LayoutBuilder(
                                    builder: (context, dividerConstraints) {
                                      if (dividerConstraints.maxWidth < 300) {
                                        return Column(
                                          children: [
                                            const Divider(),
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 8)),
                                              child: Text(
                                                AppStrings.signupSocialDivider,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 12),
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
                                            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 12)),
                                            child: Text(
                                              AppStrings.signupSocialDivider,
                                              style: TextStyle(
                                                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 12),
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
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
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
                                  Gap(ResponsiveHelper.responsiveSpacingCompat(context, mobile: 26)),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: AppStrings.signupHasAccountPrefix,
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: AppStrings.signupSignInLink,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.white 
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
