import 'package:flutter/material.dart';

/// Size classes based on width (not device type)
enum SizeClass {
  xs, // < 360
  sm, // 360 - 600
  md, // 600 - 900
  lg, // 900 - 1200
  xl, // >= 1200
}

class ResponsiveHelper {
  // Base design width for scaling calculations
  static const double baseDesignWidth = 375.0;
  
  // Size class breakpoints (width-based) - fluid breakpoints
  static const double xsMax = 360.0;  // xs < 360
  static const double smMax = 600.0;  // sm 360-599
  static const double mdMax = 840.0;  // md 600-839
  static const double lgMax = 1200.0; // lg 840-1199, xl >= 1200
  
  // Max content width for wide screens (desktop/web)
  static const double maxContentWidth = 1400.0;

  // Get screen width from context or constraints
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  // Get screen width from constraints (for LayoutBuilder)
  static double widthFromConstraints(BoxConstraints constraints) {
    return constraints.maxWidth;
  }

  // Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  // Get size class from width - fluid breakpoints
  static SizeClass getSizeClass(double width) {
    if (width < xsMax) return SizeClass.xs;      // < 360
    if (width < smMax) return SizeClass.sm;      // 360-599
    if (width < mdMax) return SizeClass.md;      // 600-839
    if (width < lgMax) return SizeClass.lg;      // 840-1199
    return SizeClass.xl;                         // >= 1200
  }
  
  // Get effective width for scaling (clamped to maxContentWidth for web/desktop)
  static double effectiveWidth(BuildContext context) {
    final screenWidth = ResponsiveHelper.screenWidth(context);
    return screenWidth < maxContentWidth ? screenWidth : maxContentWidth;
  }
  
  // Get effective width from constraints
  static double effectiveWidthFromConstraints(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    return width < maxContentWidth ? width : maxContentWidth;
  }
  
  // Get size class from context
  static SizeClass sizeClass(BuildContext context) {
    return getSizeClass(screenWidth(context));
  }
  
  // Get size class from constraints
  static SizeClass sizeClassFromConstraints(BoxConstraints constraints) {
    return getSizeClass(constraints.maxWidth);
  }
  
  // Scale value based on base design width (with clamping)
  // Uses effective width to prevent over-scaling on ultra-wide screens
  static double scaleValue(
    double baseValue,
    double currentWidth, {
    double? min,
    double? max,
  }) {
    // Use effective width (clamped to maxContentWidth) for scaling
    final effectiveW = currentWidth < maxContentWidth ? currentWidth : maxContentWidth;
    final scaleFactor = effectiveW / baseDesignWidth;
    final scaled = baseValue * scaleFactor;
    if (min != null && max != null) {
      return scaled.clamp(min, max);
    } else if (min != null) {
      return scaled < min ? min : scaled;
    } else if (max != null) {
      return scaled > max ? max : scaled;
    }
    return scaled;
  }
  
  // Scale value from context - uses effective width for web/desktop
  static double scaleValueFromContext(
    BuildContext context,
    double baseValue, {
    double? min,
    double? max,
  }) {
    return scaleValue(baseValue, effectiveWidth(context), min: min, max: max);
  }
  
  // Scale value from constraints - uses effective width
  static double scaleValueFromConstraints(
    BoxConstraints constraints,
    double baseValue, {
    double? min,
    double? max,
  }) {
    return scaleValue(baseValue, effectiveWidthFromConstraints(constraints), min: min, max: max);
  }
  
  // Legacy device-based methods (kept for backward compatibility, but deprecated)
  @Deprecated('Use sizeClass instead')
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < smMax;
  }

  @Deprecated('Use sizeClass instead')
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= smMax && width < lgMax;
  }

  @Deprecated('Use sizeClass instead')
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= lgMax;
  }

  // Get responsive padding based on size class
  static EdgeInsets responsivePadding(BuildContext context) {
    final size = sizeClass(context);
    switch (size) {
      case SizeClass.xs:
        return const EdgeInsets.all(16);
      case SizeClass.sm:
        return const EdgeInsets.all(20);
      case SizeClass.md:
        return const EdgeInsets.all(24);
      case SizeClass.lg:
        return const EdgeInsets.all(28);
      case SizeClass.xl:
        return const EdgeInsets.all(32);
    }
  }
  
  // Get responsive padding from constraints
  static EdgeInsets responsivePaddingFromConstraints(BoxConstraints constraints) {
    final size = sizeClassFromConstraints(constraints);
    switch (size) {
      case SizeClass.xs:
        return const EdgeInsets.all(16);
      case SizeClass.sm:
        return const EdgeInsets.all(20);
      case SizeClass.md:
        return const EdgeInsets.all(24);
      case SizeClass.lg:
        return const EdgeInsets.all(28);
      case SizeClass.xl:
        return const EdgeInsets.all(32);
    }
  }

  // Get responsive font size based on size class (with system text scaling)
  static double responsiveFontSize(
    BuildContext context, {
    required double base,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? min,
    double? max,
  }) {
    final size = sizeClass(context);
    double fontSize;
    switch (size) {
      case SizeClass.xs:
        fontSize = xs ?? base * 0.9;
        break;
      case SizeClass.sm:
        fontSize = sm ?? base;
        break;
      case SizeClass.md:
        fontSize = md ?? base * 1.1;
        break;
      case SizeClass.lg:
        fontSize = lg ?? base * 1.2;
        break;
      case SizeClass.xl:
        fontSize = xl ?? base * 1.3;
        break;
    }
    
    // Apply system text scaling (respect accessibility)
    final textScale = MediaQuery.of(context).textScaleFactor;
    fontSize = fontSize * textScale;
    
    // Clamp if min/max provided
    if (min != null && max != null) {
      fontSize = fontSize.clamp(min, max);
    } else if (min != null) {
      fontSize = fontSize < min ? min : fontSize;
    } else if (max != null) {
      fontSize = fontSize > max ? max : fontSize;
    }
    
    return fontSize;
  }
  
  // Legacy method for backward compatibility - converts mobile/tablet/desktop to base/size classes
  static double responsiveFontSizeLegacy(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveFontSize(
      context,
      base: mobile,
      sm: mobile,
      md: tablet ?? mobile * 1.2,
      lg: desktop ?? mobile * 1.4,
    );
  }
  
  // Backward compatibility wrapper - accepts mobile parameter and converts to base
  static double responsiveFontSizeCompat(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveFontSize(
      context,
      base: mobile,
      sm: mobile,
      md: tablet,
      lg: desktop,
    );
  }

  // Get responsive spacing based on size class
  static double responsiveSpacing(
    BuildContext context, {
    required double base,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? min,
    double? max,
  }) {
    final size = sizeClass(context);
    double spacing;
    switch (size) {
      case SizeClass.xs:
        spacing = xs ?? base * 0.85;
        break;
      case SizeClass.sm:
        spacing = sm ?? base;
        break;
      case SizeClass.md:
        spacing = md ?? base * 1.15;
        break;
      case SizeClass.lg:
        spacing = lg ?? base * 1.3;
        break;
      case SizeClass.xl:
        spacing = xl ?? base * 1.5;
        break;
    }
    
    // Clamp if min/max provided
    if (min != null && max != null) {
      spacing = spacing.clamp(min, max);
    } else if (min != null) {
      spacing = spacing < min ? min : spacing;
    } else if (max != null) {
      spacing = spacing > max ? max : spacing;
    }
    
    return spacing;
  }
  
  // Get responsive spacing from constraints
  static double responsiveSpacingFromConstraints(
    BoxConstraints constraints, {
    required double base,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? min,
    double? max,
  }) {
    final size = sizeClassFromConstraints(constraints);
    double spacing;
    switch (size) {
      case SizeClass.xs:
        spacing = xs ?? base * 0.85;
        break;
      case SizeClass.sm:
        spacing = sm ?? base;
        break;
      case SizeClass.md:
        spacing = md ?? base * 1.15;
        break;
      case SizeClass.lg:
        spacing = lg ?? base * 1.3;
        break;
      case SizeClass.xl:
        spacing = xl ?? base * 1.5;
        break;
    }
    
    if (min != null && max != null) {
      spacing = spacing.clamp(min, max);
    } else if (min != null) {
      spacing = spacing < min ? min : spacing;
    } else if (max != null) {
      spacing = spacing > max ? max : spacing;
    }
    
    return spacing;
  }
  
  // Legacy method for backward compatibility
  static double responsiveSpacingLegacy(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveSpacing(
      context,
      base: mobile,
      sm: mobile,
      md: tablet ?? mobile * 1.2,
      lg: desktop ?? mobile * 1.4,
    );
  }
  
  // Backward compatibility wrapper - accepts mobile parameter and converts to base
  static double responsiveSpacingCompat(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveSpacing(
      context,
      base: mobile,
      sm: mobile,
      md: tablet,
      lg: desktop,
    );
  }

  // Get responsive width percentage
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  // Get responsive height percentage
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  // Get responsive value based on size class
  static T responsiveValue<T>(
    BuildContext context, {
    required T base,
    T? xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    final size = sizeClass(context);
    switch (size) {
      case SizeClass.xs:
        return xs ?? base;
      case SizeClass.sm:
        return sm ?? base;
      case SizeClass.md:
        return md ?? base;
      case SizeClass.lg:
        return lg ?? base;
      case SizeClass.xl:
        return xl ?? base;
    }
  }
  
  // Get responsive value from constraints
  static T responsiveValueFromConstraints<T>(
    BoxConstraints constraints, {
    required T base,
    T? xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    final size = sizeClassFromConstraints(constraints);
    switch (size) {
      case SizeClass.xs:
        return xs ?? base;
      case SizeClass.sm:
        return sm ?? base;
      case SizeClass.md:
        return md ?? base;
      case SizeClass.lg:
        return lg ?? base;
      case SizeClass.xl:
        return xl ?? base;
    }
  }
  
  // Legacy method for backward compatibility
  static T responsiveValueLegacy<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return responsiveValue(
      context,
      base: mobile,
      sm: mobile,
      md: tablet ?? mobile,
      lg: desktop ?? tablet ?? mobile,
    );
  }
  
  // Backward compatibility wrapper - accepts mobile parameter and converts to base
  static T responsiveValueCompat<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return responsiveValue(
      context,
      base: mobile,
      sm: mobile,
      md: tablet,
      lg: desktop,
    );
  }

  // Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Get text scale factor (respect system scaling, but clamp to reasonable range)
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);
  }

  // Clamp a value when scaling with screen width (legacy - use scaleValue instead)
  @Deprecated('Use scaleValue instead')
  static double clampScaledValue(
    BuildContext context,
    double percent, {
    required double min,
    required double max,
  }) {
    final scaled = screenWidth(context) * (percent / 100);
    return scaled.clamp(min, max);
  }
  
  // Clamp a value when scaling with constraints
  static double clampScaledValueFromConstraints(
    BoxConstraints constraints,
    double percent, {
    required double min,
    required double max,
  }) {
    final scaled = constraints.maxWidth * (percent / 100);
    return scaled.clamp(min, max);
  }

  // Get adaptive grid column count based purely on width
  static int gridColumnCount(BuildContext context, {
    int? xs,
    int? sm,
    int? md,
    int? lg,
    int? xl,
  }) {
    final size = sizeClass(context);
    switch (size) {
      case SizeClass.xs:
        return xs ?? 1;
      case SizeClass.sm:
        return sm ?? 2;
      case SizeClass.md:
        return md ?? 3;
      case SizeClass.lg:
        return lg ?? 4;
      case SizeClass.xl:
        return xl ?? 5;
    }
  }
  
  // Get adaptive grid column count from constraints
  static int gridColumnCountFromConstraints(BoxConstraints constraints, {
    int? xs,
    int? sm,
    int? md,
    int? lg,
    int? xl,
  }) {
    final size = sizeClassFromConstraints(constraints);
    switch (size) {
      case SizeClass.xs:
        return xs ?? 1;
      case SizeClass.sm:
        return sm ?? 2;
      case SizeClass.md:
        return md ?? 3;
      case SizeClass.lg:
        return lg ?? 4;
      case SizeClass.xl:
        return xl ?? 5;
    }
  }
  
  // Calculate optimal grid columns based on item width and available space
  static int calculateGridColumns({
    required double availableWidth,
    required double itemMinWidth,
    double spacing = 12.0,
  }) {
    final columns = ((availableWidth + spacing) / (itemMinWidth + spacing)).floor();
    return columns.clamp(1, 6);
  }

  // Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    final size = sizeClass(context);
    switch (size) {
      case SizeClass.xs:
        return const EdgeInsets.symmetric(horizontal: 12);
      case SizeClass.sm:
        return const EdgeInsets.symmetric(horizontal: 16);
      case SizeClass.md:
        return const EdgeInsets.symmetric(horizontal: 24);
      case SizeClass.lg:
        return const EdgeInsets.symmetric(horizontal: 28);
      case SizeClass.xl:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }
  
  // Get responsive horizontal padding from constraints
  static EdgeInsets responsiveHorizontalPaddingFromConstraints(BoxConstraints constraints) {
    final size = sizeClassFromConstraints(constraints);
    switch (size) {
      case SizeClass.xs:
        return const EdgeInsets.symmetric(horizontal: 12);
      case SizeClass.sm:
        return const EdgeInsets.symmetric(horizontal: 16);
      case SizeClass.md:
        return const EdgeInsets.symmetric(horizontal: 24);
      case SizeClass.lg:
        return const EdgeInsets.symmetric(horizontal: 28);
      case SizeClass.xl:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  // Get responsive vertical padding
  static EdgeInsets responsiveVerticalPadding(BuildContext context) {
    final size = sizeClass(context);
    switch (size) {
      case SizeClass.xs:
        return const EdgeInsets.symmetric(vertical: 8);
      case SizeClass.sm:
        return const EdgeInsets.symmetric(vertical: 12);
      case SizeClass.md:
        return const EdgeInsets.symmetric(vertical: 16);
      case SizeClass.lg:
        return const EdgeInsets.symmetric(vertical: 20);
      case SizeClass.xl:
        return const EdgeInsets.symmetric(vertical: 24);
    }
  }

  // Check if in landscape mode
  static bool isLandscape(BuildContext context) {
    return screenWidth(context) > screenHeight(context);
  }
  
  // Check if in landscape mode from constraints
  static bool isLandscapeFromConstraints(BoxConstraints constraints) {
    return constraints.maxWidth > constraints.maxHeight;
  }
}
