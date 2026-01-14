import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon; // ✅ for left icon (eye) in RTL
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
        // label فوق الحقل
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),

        // ✅ 322x50 style (height fixed)
        Container(
          height: 50, // ✅ exactly like design
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
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
            textAlignVertical: TextAlignVertical.center, // ✅ vertically centered
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),

              // ✅ icons inside the field
              prefixIcon: prefixIcon, // shows on LEFT in RTL
              suffixIcon: suffixIcon, // shows on RIGHT in RTL

              // ✅ remove borders
              border: InputBorder.none,

              // ✅ padding tuned for height 50
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
