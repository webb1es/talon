import 'package:flutter/material.dart';

import '../../core/theme/app_animations.dart';

/// Wraps any widget with a hover-activated background highlight.
class HoverHighlight extends StatefulWidget {
  final BorderRadius borderRadius;
  final Color? hoverColor;
  final Widget child;

  const HoverHighlight({
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.hoverColor,
    required this.child,
  });

  @override
  State<HoverHighlight> createState() => _HoverHighlightState();
}

class _HoverHighlightState extends State<HoverHighlight> {
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.hoverColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.06);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.spring,
        decoration: BoxDecoration(
          color: _hovering ? color : Colors.transparent,
          borderRadius: widget.borderRadius,
        ),
        child: widget.child,
      ),
    );
  }
}
