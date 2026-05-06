import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/presentation/widgets/auth/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/auth/login_row_cta.dart';
import 'package:manzili_mobile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';
import 'package:gap/gap.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _validationHint;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#\$&*~%]').hasMatch(password)) return false;
    return true;
  }

  void _handleReset() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.isEmpty || confirm.isEmpty) {
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

    if (password != confirm) {
      setState(() {
        _validationHint = AppLocalizations.of(context)!.errPasswordMismatch;
      });
      return;
    }

    setState(() {
      _validationHint = null;
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    
    // Navigate back to sign in
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.successPasswordReset)),
    );
    context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.btnResetPassword),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ResponsiveMaxWidth(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.password,
                    size: ResponsiveHelper.responsiveValueCompat(context, mobile: 80.0, tablet: 100.0),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(24),
                  Text(
                    AppLocalizations.of(context)!.btnResetPassword,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 15),
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const Gap(32),
                  CustomTextField(
                    label: AppLocalizations.of(context)!.fieldNewPassword,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    AppLocalizations.of(context)!.passwordRequirements,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 12),
                      color: AppColors.textHint,
                    ),
                  ),
                  const Gap(16),
                  CustomTextField(
                    label: AppLocalizations.of(context)!.fieldConfirmPassword,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  if (_validationHint != null) ...[
                    const Gap(8),
                    Text(
                      _validationHint!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Gap(32),
                  LoginRowCTA(
                    text: AppLocalizations.of(context)!.btnResetPassword,
                    onTap: _isLoading ? null : _handleReset,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
