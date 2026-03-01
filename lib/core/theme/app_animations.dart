import 'package:flutter/animation.dart';

class AppAnimations {
  AppAnimations._();

  // Durations
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);

  // Curves
  static const spring = Curves.easeOutCubic;
  static const snappy = Curves.easeOutBack;
  static const smooth = Curves.easeInOut;
}
