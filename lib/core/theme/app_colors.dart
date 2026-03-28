import 'package:flutter/material.dart';

/// Manzili design tokens — spec Section 3 (strict palette).
class AppColors {
  // —— Base palette (reference swatches) ——
  static const Color tangerineDream = Color(0xFFED8E5E);
  /// Warm accent — #ED8E3C
  static const Color tigerOrange = Color(0xFFED8E3C);
  /// Primary CTA only — #DD643C
  static const Color spicyPaprika = Color(0xFFDD643C);
  /// Headings — #6B7B8C
  static const Color slateGrey = Color(0xFF6B7B8C);
  /// Neutral — #9BA8B4
  static const Color coolSteel = Color(0xFF9BA8B4);
  /// Nature accent — #769E66
  static const Color sageGreen = Color(0xFF769E66);

  // —— Brand (semantic) ——
  static const Color primary = spicyPaprika;
  static const Color secondary = tigerOrange;
  static const Color accent = spicyPaprika;
  /// App bar titles & section headings (spec: headings color).
  static const Color heading = slateGrey;

  // —— Surfaces ——
  static const Color background = Color(0xFFFAF8F6);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF5F5F5);
  /// Role / filter chip when unselected
  static const Color roleUnselectedBackground = Color(0xFFEBECEE);

  // —— Text ——
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = slateGrey;
  static const Color textHint = coolSteel;

  static const Color success = sageGreen;
  static const Color error = Color(0xFFE57373);
  static const Color border = Color(0xFFE8E4E0);
  static const Color divider = Color(0xFFE0E0E0);

  /// Status: نشطة / active
  static const Color statusActive = Color(0xFF43A047);
  /// Status: موقوفة / مسودة / inactive
  static const Color statusInactive = Color(0xFF9E9E9E);
  /// Status: معلّق / warning
  static const Color statusPending = Color(0xFFFFC107);
  static const Color softShadow = Color(0x1A000000);

  /// Product badges (e.g. recommended ribbon) — distinct from [statusPending]
  static const Color badgeRecommended = Color(0xFFF4B400);

  /// Gradient for compact auth actions (sign-in / sign-up row control)
  static const Color authGradientStart = Color(0xFFFF8D28);
  static const Color authGradientEnd = Color(0xFFC20AFA);
}
