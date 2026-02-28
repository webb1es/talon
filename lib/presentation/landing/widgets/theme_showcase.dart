import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ThemeShowcase extends StatelessWidget {
  const ThemeShowcase({super.key});

  static const _themes = [
    (name: 'Predator', type: AppThemeType.predator, light: AppColors.predatorLight, dark: AppColors.predatorDark),
    (name: 'Precision', type: AppThemeType.precision, light: AppColors.precisionLight, dark: AppColors.precisionDark),
    (name: 'Strike', type: AppThemeType.strike, light: AppColors.strikeLight, dark: AppColors.strikeDark),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: 48,
      ),
      child: Column(
        children: [
          Text(
            AppStrings.themeShowcase,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.featureThemesDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              for (final t in _themes)
                _ThemeCard(name: t.name, light: t.light, dark: t.dark),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String name;
  final AppColors light;
  final AppColors dark;

  const _ThemeCard({
    required this.name,
    required this.light,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Swatch(color: light.primary, label: 'Light'),
                  const SizedBox(width: 8),
                  _Swatch(color: dark.primary, label: 'Dark'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Swatch(color: light.background, label: 'BG'),
                  const SizedBox(width: 4),
                  _Swatch(color: light.surface, label: 'Srf'),
                  const SizedBox(width: 4),
                  _Swatch(color: dark.background, label: 'BG'),
                  const SizedBox(width: 4),
                  _Swatch(color: dark.surface, label: 'Srf'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String label;

  const _Swatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
