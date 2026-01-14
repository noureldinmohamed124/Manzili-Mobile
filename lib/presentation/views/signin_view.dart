import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manzili_mobile/presentation/widgets/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/login_row_cta.dart';
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
                                fontSize: 38, // ✅ bigger
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'سجل الدخول إلى حسابك',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15, // ✅ bigger
                                color: AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Role Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _RoleButton(
                                    label: 'مشتري',
                                    icon: Icons.shopping_cart_outlined,
                                    isSelected: _selectedRole == 'buyer',
                                    onTap: () =>
                                        setState(() => _selectedRole = 'buyer'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _RoleButton(
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
                                  size: 22, // ✅ bigger icon
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
                                      fontSize: 13, // ✅ bigger
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
                                        fontSize: 13, // ✅ bigger
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
                                      fontSize: 12, // ✅ bigger
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
                                _SocialLoginButton(asset: AppAssets.googleIcon),
                                const SizedBox(width: 14,height: 26),
                                _SocialLoginButton(asset: AppAssets.twitterIcon),
                                const SizedBox(width: 14,height: 26),
                                _SocialLoginButton(asset: AppAssets.facebookIcon),
                              ],
                            ),

                            const SizedBox(height: 26),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'ليس لديك حساب؟ ',
                                style: const TextStyle(
                                  fontSize: 14, // ✅ bigger
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
                child: Image.asset(
                  AppAssets.gradientBottomLeft,
                  width: size.width * 0.20,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- Helper Widgets ---------- */

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFEFF1F4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20, // ✅ bigger icon
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14, // ✅ bigger
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String asset;

  const _SocialLoginButton({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64, // ⬅️ كانت 54
      height: 64, // ⬅️ كانت 54
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Center(
        child: asset.endsWith('.svg')
            ? SvgPicture.asset(
                asset,
                width: 50, // ⬅️ كانت 26
                height: 50,
              )
            : Image.asset(
                asset,
                width: 50, // ⬅️ كانت 26
                height: 50,
              ),
      ),
    );
  }
}
