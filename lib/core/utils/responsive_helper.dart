import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Check if device is mobile
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  // Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  // Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= desktopBreakpoint;
  }

  // Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) {
      return const EdgeInsets.all(20);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) {
      return mobile;
    } else if (width < tabletBreakpoint) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }

  // Get responsive spacing
  static double responsiveSpacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) {
      return mobile;
    } else if (width < tabletBreakpoint) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }

  // Get responsive width percentage
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  // Get responsive height percentage
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  // Get responsive value based on screen size
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) {
      return mobile;
    } else if (width < tabletBreakpoint) {
      return tablet ?? mobile;
    } else {
      return desktop ?? tablet ?? mobile;
    }
  }

  // Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Get text scale factor
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);
  }
}
