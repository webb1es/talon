import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_cubit.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  static const _themes = [
    (type: AppThemeType.predator, label: AppStrings.predator, light: AppColors.predatorLight, dark: AppColors.predatorDark),
    (type: AppThemeType.precision, label: AppStrings.precision, light: AppColors.precisionLight, dark: AppColors.precisionDark),
    (type: AppThemeType.strike, label: AppStrings.strike, light: AppColors.strikeLight, dark: AppColors.strikeDark),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ThemeCubit>();
    final state = cubit.state;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Theme selection
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(AppStrings.theme, style: theme.textTheme.titleSmall),
        ),
        for (final t in _themes)
          _ThemeOption(
            label: t.label,
            primaryLight: t.light.primary,
            primaryDark: t.dark.primary,
            selected: state.themeType == t.type,
            onTap: () => cubit.setTheme(t.type),
          ),

        const Divider(height: 32),

        // Light / Dark toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(AppStrings.appearance, style: theme.textTheme.titleSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(AppStrings.lightMode),
                icon: Icon(Icons.light_mode, size: 18),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(AppStrings.darkMode),
                icon: Icon(Icons.dark_mode, size: 18),
              ),
            ],
            selected: {state.themeMode},
            onSelectionChanged: (modes) => cubit.setMode(modes.first),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final Color primaryLight;
  final Color primaryDark;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.primaryLight,
    required this.primaryDark,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: label,
      selected: selected,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ColorDot(color: primaryLight),
            const SizedBox(width: 6),
            _ColorDot(color: primaryDark),
          ],
        ),
        title: Text(label),
        trailing: selected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
