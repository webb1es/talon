import 'package:flutter/widgets.dart';

/// Spacing constants based on 8px grid. Primary increments: 16px, 24px.
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
  static const double buttonPaddingH = 32;
  static const double buttonPaddingV = 24;
  static const double buttonSmallPaddingH = 24;
  static const double buttonSmallPaddingV = 16;
  static const double inputPaddingH = 16;
  static const double tableCellPaddingH = 24;
  static const double tableCellPaddingV = 16;

  // Heights
  static const double buttonHeight = 48;
  static const double buttonSmallHeight = 36;
  static const double inputHeight = 48;
  static const double touchTarget = 48;

  // Radius
  static const double radiusSmall = 4;
  static const double radiusCard = 8;

  // Gaps (for use in SizedBox or Gap widgets)
  static const gap4 = SizedBox.square(dimension: xs);
  static const gap8 = SizedBox.square(dimension: sm);
  static const gap16 = SizedBox.square(dimension: md);
  static const gap24 = SizedBox.square(dimension: lg);
  static const gap32 = SizedBox.square(dimension: xl);
}
