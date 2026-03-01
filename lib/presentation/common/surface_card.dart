import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

/// Container with macOS-style surface appearance: rounded corners, subtle shadow.
/// Optionally elevates on hover.
class SurfaceCard extends StatefulWidget {
  final AppColors colors;
  final EdgeInsetsGeometry padding;
  final bool hoverElevation;
  final Widget child;

  const SurfaceCard({
    super.key,
    required this.colors,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.hoverElevation = false,
    required this.child,
  });

  @override
  State<SurfaceCard> createState() => _SurfaceCardState();
}

class _SurfaceCardState extends State<SurfaceCard> {
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    final shadow = _hovering && widget.hoverElevation
        ? AppShadows.elevated(widget.colors)
        : AppShadows.card(widget.colors);

    return MouseRegion(
      onEnter: widget.hoverElevation
          ? (_) => setState(() => _hovering = true)
          : null,
      onExit: widget.hoverElevation
          ? (_) => setState(() => _hovering = false)
          : null,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.spring,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: shadow,
        ),
        child: widget.child,
      ),
    );
  }
}
