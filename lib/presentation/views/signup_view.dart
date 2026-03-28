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
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      AppAssets.gradientTop,
                      height: gradientHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: gradientHeight + ResponsiveHelper.responsiveSpacingCompat(context, mobile: 16)),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                    color: AppColors.textPrimary,
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
                                                  color: AppColors.textSecondary,
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
                                                color: AppColors.textSecondary,
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
                                    spacing: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 14),
                                    children: [
                                      SocialLoginButton(asset: AppAssets.googleIcon),
                                      SocialLoginButton(asset: AppAssets.twitterIcon),
                                      SocialLoginButton(asset: AppAssets.facebookIcon),
                                    ],
                                  ),
                                  SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 26)),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: AppStrings.signupHasAccountPrefix,
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: AppStrings.signupSignInLink,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.accent,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              context.go('/signin');
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Image.asset(
                      AppAssets.gradientBottomLeft,
                      width: gradientBottomWidth,
                      height: gradientBottomHeight,
                      fit: BoxFit.cover,
                    ),
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
