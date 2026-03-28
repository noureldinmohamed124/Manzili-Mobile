import 'package:flutter/material.dart';
import 'package:manzili_mobile/core/constants/app_assets.dart';

/// Bottom decorative PNG; stays behind scrollable content.
class AuthBottomGradient extends StatelessWidget {
  const AuthBottomGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportHeight = MediaQuery.of(context).size.height;
            final gradientHeight = (viewportHeight * 0.30).clamp(160.0, 320.0);
            final w = constraints.maxWidth;
            return SizedBox(
              width: w,
              height: gradientHeight,
              child: Image.asset(
                AppAssets.gradientBottomLeft,
                width: w,
                height: gradientHeight,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            );
          },
        ),
      ),
    );
  }
}
