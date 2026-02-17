import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon; 
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 10)),
        Container(
          height: ResponsiveHelper.clampScaledValue(context, 6.5, min: 48.0, max: 56.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveValueCompat(context, mobile: 30.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: enabled,
            onChanged: onChanged,
            textDirection: TextDirection.rtl,
            textAlignVertical: TextAlignVertical.center,
            enableInteractiveSelection: true,
            keyboardAppearance: Brightness.light, 
            style: TextStyle(
              fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(
                fontSize: ResponsiveHelper.responsiveFontSizeCompat(context, mobile: 14),
                color: AppColors.textHint,
              ),
              prefixIcon: prefixIcon, 
              suffixIcon: suffixIcon, 
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.responsiveSpacingCompat(context, mobile: 18),
                vertical: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
