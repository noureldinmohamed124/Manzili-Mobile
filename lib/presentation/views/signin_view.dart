import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:manzili_mobile/presentation/widgets/auth/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/auth/login_row_cta.dart';
import 'package:manzili_mobile/presentation/widgets/auth/role_button.dart';
import 'package:manzili_mobile/presentation/widgets/auth/social_login_button.dart';
import 'package:manzili_mobile/presentation/views/signup_view.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String _selectedRole = 'seller';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gradientHeight = size.height * 0.18;
    final gradientBottomHeight = size.height * 0.20;
    final gradientBottomWidth = size.width * 0.20;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.10,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: gradientHeight,
                  child: Image.asset(
                    AppAssets.gradientTop,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: gradientHeight + 16),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'مرحباً',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'سجل الدخول إلى حسابك',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
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
                                const SizedBox(width: 12),
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
                            const SizedBox(height: 26),
                            const CustomTextField(
                              label: 'البريد الالكتروني',
                            ),
                            const SizedBox(height: 18),
                            CustomTextField(
                              label: 'كلمة المرور',
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
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) => setState(
                                          () => _rememberMe = v ?? false),
                                      activeColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.4,
                                      ),
                                    ),
                                    const Text(
                                      'تذكرني',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: LoginRowCTA(
                                  text: 'سجل الدخول',
                                  onTap: () {},
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: const [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'أو سجل باستخدام وسائل التواصل الاجتماعي',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SocialLoginButton(asset: AppAssets.googleIcon),
                                const SizedBox(width: 14,height: 26),
                                SocialLoginButton(asset: AppAssets.twitterIcon),
                                const SizedBox(width: 14,height: 26),
                                SocialLoginButton(asset: AppAssets.facebookIcon),
                              ],
                            ),
                            const SizedBox(height: 26),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'ليس لديك حساب؟ ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'إنشاء حساب',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SignupView(),
                                          ),
                                        );
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
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  width: gradientBottomWidth,
                  height: gradientBottomHeight,
                  child: Image.asset(
                    AppAssets.gradientBottomLeft,
                    fit: BoxFit.fill,
                    alignment: Alignment.bottomLeft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
