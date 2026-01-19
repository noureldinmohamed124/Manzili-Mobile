import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:manzili_mobile/presentation/widgets/auth/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/auth/login_row_cta.dart';
import 'package:manzili_mobile/presentation/widgets/auth/role_button.dart';
import 'package:manzili_mobile/presentation/widgets/auth/social_login_button.dart';
import 'package:manzili_mobile/presentation/views/signin_view.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  bool _obscurePassword = true;
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
                              'انشأ حساب جديد',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 38, 
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
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
                              label: 'الاسم بالكامل',
                            ),
                            const SizedBox(height: 18),
                            const CustomTextField(
                              label: 'البريد الاكتروني',
                            ),
                            const SizedBox(height: 18),
                            CustomTextField(
                              label: 'كلمه المرور',
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
                            const SizedBox(height: 24),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: LoginRowCTA(
                                  text: 'إنشاء حساب',
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
                                text: 'لديك حساب؟ ',
                                style: const TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'سجل الدخول',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SigninView(),
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
