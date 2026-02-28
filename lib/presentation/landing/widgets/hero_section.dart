import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLearnMore;

  const HeroSection({
    super.key,
    required this.onGetStarted,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: isMobile ? 48 : 96,
      ),
      child: Column(
        children: [
          Text(
            AppStrings.appName,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.heroHeadline,
            textAlign: TextAlign.center,
            style: (isMobile
                    ? theme.textTheme.headlineMedium
                    : theme.textTheme.displaySmall)
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              AppStrings.heroSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              Semantics(
                label: AppStrings.getStarted,
                child: ElevatedButton(
                  onPressed: onGetStarted,
                  child: const Text(AppStrings.getStarted),
                ),
              ),
              Semantics(
                label: AppStrings.learnMore,
                child: OutlinedButton(
                  onPressed: onLearnMore,
                  child: const Text(AppStrings.learnMore),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
