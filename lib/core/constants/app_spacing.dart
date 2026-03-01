import 'package:flutter/widgets.dart';

/// Spacing constants based on 8px grid with macOS-density adjustments.
class AppSpacing {
  AppSpacing._();

  // Base units
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Component-specific
  static const double cardPadding = 24;
  static const double buttonPaddingH = 20;
  static const double buttonPaddingV = 10;
  static const double buttonSmallPaddingH = 14;
  static const double buttonSmallPaddingV = 6;
  static const double inputPaddingH = 12;
  static const double tableCellPaddingH = 24;
  static const double tableCellPaddingV = 16;

  // Heights
  static const double buttonHeight = 32;
  static const double buttonSmallHeight = 26;
  static const double inputHeight = 28;
  static const double touchTarget = 44;
  static const double toolbarHeight = 52;
  static const double sidebarWidth = 220;

  // Radius
  static const double radiusSmall = 6;
  static const double radiusMedium = 8;
  static const double radiusCard = 10;
  static const double radiusLarge = 12;
  static const double radiusXl = 16;

  // Shadow blur
  static const double shadowBlurCard = 8;
  static const double shadowBlurElevated = 16;
  static const double shadowBlurDialog = 32;
  static const double shadowOffsetCard = 2;
  static const double shadowOffsetElevated = 4;
  static const double shadowOffsetDialog = 8;

  // Gaps (for use in SizedBox or Gap widgets)
  static const gap4 = SizedBox.square(dimension: xs);
  static const gap8 = SizedBox.square(dimension: sm);
  static const gap16 = SizedBox.square(dimension: md);
  static const gap24 = SizedBox.square(dimension: lg);
  static const gap32 = SizedBox.square(dimension: xl);
}
