import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../widgets/cta_section.dart';
import '../widgets/feature_grid.dart';
import '../widgets/hero_section.dart';
import '../widgets/theme_showcase.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featuresKey = GlobalKey();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(
              onGetStarted: () => context.go(AppRoutes.login),
              onLearnMore: () => Scrollable.ensureVisible(
                featuresKey.currentContext!,
                duration: const Duration(milliseconds: 400),
              ),
            ),
            const Divider(height: 1),
            KeyedSubtree(
              key: featuresKey,
              child: const FeatureGrid(),
            ),
            const Divider(height: 1),
            const ThemeShowcase(),
            const Divider(height: 1),
            CtaSection(
              onGetStarted: () => context.go(AppRoutes.login),
              onViewOnePager: () => context.go(AppRoutes.onePager),
            ),
          ],
        ),
      ),
    );
  }
}
