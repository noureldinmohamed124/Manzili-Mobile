import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/presentation/widgets/auth/custom_text_field.dart';
import 'package:manzili_mobile/presentation/widgets/auth/login_row_cta.dart';
import 'package:manzili_mobile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/responsive_max_width.dart';
import 'package:gap/gap.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  String? _validationHint;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _validationHint = AppLocalizations.of(context)!.errInvalidRequest;
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
      _validationHint = AppLocalizations.of(context)!.forgotPasswordInstruction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.forgotPassword),
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
                    Icons.lock_reset,
                    size: ResponsiveHelper.responsiveValueCompat(context, mobile: 80.0, tablet: 100.0),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(24),
                  Text(
                    AppLocalizations.of(context)!.forgotPasswordInstruction,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 15),
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const Gap(32),
                  CustomTextField(
                    label: AppLocalizations.of(context)!.fieldEmailOrPhone,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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
                    text: AppLocalizations.of(context)!.btnSendReset,
                    onTap: _isLoading ? null : _handleReset,
                  ),
                  const Gap(16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      AppLocalizations.of(context)!.backToSignIn,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
