import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// A widget that constrains content to a maximum width and centers it
/// Useful for preventing content from stretching infinitely on wide screens
class ResponsiveMaxWidth extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  const ResponsiveMaxWidth({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMaxWidth = maxWidth ?? ResponsiveHelper.maxContentWidth;
        final effectivePadding = padding ?? ResponsiveHelper.responsivePaddingFromConstraints(constraints);
        
        // If content is narrower than max width, center it
        if (constraints.maxWidth > effectiveMaxWidth) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: effectiveMaxWidth,
                minWidth: 0,
              ),
              child: Padding(
                padding: effectivePadding,
                child: child,
              ),
            ),
          );
        }
        
        // Otherwise, just apply padding
        return Padding(
          padding: effectivePadding,
          child: child,
        );
      },
    );
  }
}
