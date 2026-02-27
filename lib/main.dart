import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

void main() {
  runApp(const TalonApp());
}

class TalonApp extends StatelessWidget {
  const TalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: themeState.themeData,
            home: const _ThemeDemo(),
          );
        },
      ),
    );
  }
}

/// Temporary demo screen to verify all 6 theme variations.
class _ThemeDemo extends StatelessWidget {
  const _ThemeDemo();

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final themeState = context.watch<ThemeCubit>().state;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: theme.textTheme.headlineMedium,
        ),
        actions: [
          Semantics(
            label: 'Toggle dark mode',
            child: IconButton(
              icon: Icon(
                themeState.isDark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: themeCubit.toggleMode,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.welcome(themeState.themeType),
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tagline,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Text('Theme', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            SegmentedButton<AppThemeType>(
              segments: const [
                ButtonSegment(
                  value: AppThemeType.predator,
                  label: Text('Predator'),
                ),
                ButtonSegment(
                  value: AppThemeType.precision,
                  label: Text('Precision'),
                ),
                ButtonSegment(
                  value: AppThemeType.strike,
                  label: Text('Strike'),
                ),
              ],
              selected: {themeState.themeType},
              onSelectionChanged: (selected) {
                themeCubit.setTheme(selected.first);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Primary Button'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Secondary Button'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('Tertiary Button'),
            ),
            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Sample input',
                hintText: 'Type something...',
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppStrings.loading(themeState.themeType),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
