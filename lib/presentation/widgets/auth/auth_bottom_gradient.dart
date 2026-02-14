import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

/// A bottom gradient widget that stays anchored to the bottom as a background layer.
/// Works correctly on all screen sizes, including when keyboard is open.
/// The PNG gradient spans full width and is positioned at the bottom center.
class AuthBottomGradient extends StatelessWidget {
  const AuthBottomGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        // Ignore pointer so it doesn't interfere with scrolling
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate height from viewport height with proper clamping
            // Height should be 30% of viewport, clamped between 160 and 320
            final viewportHeight = MediaQuery.of(context).size.height;
            final gradientHeight = (viewportHeight * 0.30).clamp(160.0, 320.0);

            return SizedBox(
              height: gradientHeight,
              width: double.infinity, // Span full width
              child: Image.asset(
                AppAssets.gradientBottomLeft,
                fit: BoxFit.cover, // Cover the area without stretching
                alignment: Alignment.bottomCenter,
              ),
            );
          },
        ),
      ),
    );
  }
}
