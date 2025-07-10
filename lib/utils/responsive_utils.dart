import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;

  // Aspect ratio breakpoints
  static const double phoneAspectRatio = 0.6;
  static const double tabletAspectRatio = 0.75;

  // Height breakpoints for different phone sizes
  static const double shortScreen = 600;
  static const double mediumScreen = 800;
  static const double tallScreen = 900;
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Screen size category
enum ScreenSize { small, medium, large, extraLarge }

/// Responsive utility functions for adaptive UI
class ResponsiveUtils {
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < ResponsiveBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return DeviceType.mobile;
    } else if (width < ResponsiveBreakpoints.desktop) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < ResponsiveBreakpoints.mobile) {
      return ScreenSize.small;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return ScreenSize.medium;
    } else if (width < ResponsiveBreakpoints.desktop) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  /// Check if screen is small (narrow phones)
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 360 || size.height < ResponsiveBreakpoints.shortScreen;
  }

  /// Check if screen is in landscape mode (always false since app is portrait-only)
  static bool isLandscape(BuildContext context) => false;

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    final padding = switch (deviceType) {
      DeviceType.mobile => mobile ?? 16.0,
      DeviceType.tablet => tablet ?? 24.0,
      DeviceType.desktop => desktop ?? 32.0,
    };

    return EdgeInsets.all(padding);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    final baseFontSize = switch (deviceType) {
      DeviceType.mobile => mobile ?? 14.0,
      DeviceType.tablet => tablet ?? 16.0,
      DeviceType.desktop => desktop ?? 18.0,
    };

    // Apply text scale factor from system settings
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return baseFontSize * textScaleFactor.clamp(0.8, 1.3);
  }

  /// Get responsive width based on screen size
  static double getResponsiveWidth(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      DeviceType.mobile => mobile ?? MediaQuery.of(context).size.width,
      DeviceType.tablet => tablet ?? MediaQuery.of(context).size.width * 0.8,
      DeviceType.desktop => desktop ?? 600.0,
    };
  }

  /// Get optimal grid count for different screen sizes
  static int getGridCount(
    BuildContext context, {
    int? mobile,
    int? tablet,
    int? desktop,
  }) {
    final screenSize = getScreenSize(context);
    return switch (screenSize) {
      ScreenSize.small => mobile ?? 2,
      ScreenSize.medium => mobile ?? 2,
      ScreenSize.large => tablet ?? 3,
      ScreenSize.extraLarge => desktop ?? 4,
    };
  }

  /// Get responsive card aspect ratio
  static double getCardAspectRatio(BuildContext context) {
    final deviceType = getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => 0.55,
      DeviceType.tablet => 0.6,
      DeviceType.desktop => 0.75,
    };
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      DeviceType.mobile => mobile ?? 8.0,
      DeviceType.tablet => tablet ?? 12.0,
      DeviceType.desktop => desktop ?? 16.0,
    };
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      DeviceType.mobile => mobile ?? 24.0,
      DeviceType.tablet => tablet ?? 28.0,
      DeviceType.desktop => desktop ?? 32.0,
    };
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      DeviceType.mobile => 48.0,
      DeviceType.tablet => 52.0,
      DeviceType.desktop => 56.0,
    };
  }

  /// Get responsive modal height
  static double getResponsiveModalHeight(
    BuildContext context, {
    double mobileRatio = 0.9,
    double tabletRatio = 0.8,
    double desktopRatio = 0.7,
  }) {
    final deviceType = getDeviceType(context);
    final screenHeight = MediaQuery.of(context).size.height;

    final ratio = switch (deviceType) {
      DeviceType.mobile => mobileRatio,
      DeviceType.tablet => tabletRatio,
      DeviceType.desktop => desktopRatio,
    };

    return screenHeight * ratio;
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      DeviceType.mobile => mobile ?? 8.0,
      DeviceType.tablet => tablet ?? 12.0,
      DeviceType.desktop => desktop ?? 16.0,
    };
  }

  /// Get optimal content width for reading
  static double getOptimalContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => screenWidth * 0.9,
      DeviceType.tablet => screenWidth * 0.8,
      DeviceType.desktop => 800.0,
    };
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// Get responsive game grid dimensions
  static GridDimensions getGameGridDimensions(BuildContext context) {
    final deviceType = getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => GridDimensions(
          crossAxisCount: 2,
          childAspectRatio: getCardAspectRatio(context),
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
        ),
      DeviceType.tablet => GridDimensions(
          crossAxisCount: 3,
          childAspectRatio: getCardAspectRatio(context),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
      DeviceType.desktop => GridDimensions(
          crossAxisCount: 4,
          childAspectRatio: getCardAspectRatio(context),
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
    };
  }
}

/// Grid dimensions helper class
class GridDimensions {
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const GridDimensions({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
  });
}

/// Responsive widget that builds different layouts based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);

    return switch (deviceType) {
      DeviceType.mobile => mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.desktop => desktop ?? tablet ?? mobile,
    };
  }
}

/// Responsive text widget with automatic font scaling
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      mobile: mobileFontSize,
      tablet: tabletFontSize,
      desktop: desktopFontSize,
    );

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: responsiveFontSize,
      ),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

/// Responsive container with automatic padding and sizing
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? mobilePadding;
  final double? tabletPadding;
  final double? desktopPadding;
  final Color? color;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final bool useOptimalWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.useOptimalWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ??
        ResponsiveUtils.getResponsivePadding(
          context,
          mobile: mobilePadding,
          tablet: tabletPadding,
          desktop: desktopPadding,
        );

    final containerWidth = useOptimalWidth
        ? ResponsiveUtils.getOptimalContentWidth(context)
        : width;

    return Container(
      width: containerWidth,
      height: height,
      padding: responsivePadding,
      decoration:
          decoration ?? (color != null ? BoxDecoration(color: color) : null),
      child: child,
    );
  }
}
