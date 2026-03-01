import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Frosted glass container with backdrop blur and tint.
/// Falls back to solid color on web (BackdropFilter is expensive with shaders).
class FrostedGlass extends StatelessWidget {
  final Color? tint;
  final double blur;
  final BorderRadius borderRadius;
  final Widget child;

  const FrostedGlass({
    super.key,
    this.tint,
    this.blur = 20,
    this.borderRadius = BorderRadius.zero,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTint = tint ??
        (Theme.of(context).brightness == Brightness.light
            ? const Color(0xB3FFFFFF)
            : const Color(0xB31A1A1A));

    if (kIsWeb) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          color: effectiveTint,
          child: child,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: effectiveTint,
          child: child,
        ),
      ),
    );
  }
}
