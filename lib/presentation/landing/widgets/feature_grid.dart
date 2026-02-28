import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  static const _features = [
    (icon: Icons.bolt, title: AppStrings.featurePos, desc: AppStrings.featurePosDesc),
    (icon: Icons.cloud_off, title: AppStrings.featureOffline, desc: AppStrings.featureOfflineDesc),
    (icon: Icons.store, title: AppStrings.featureMultiStore, desc: AppStrings.featureMultiStoreDesc),
    (icon: Icons.bar_chart, title: AppStrings.featureReports, desc: AppStrings.featureReportsDesc),
    (icon: Icons.palette, title: AppStrings.featureThemes, desc: AppStrings.featureThemesDesc),
    (icon: Icons.shield, title: AppStrings.featureSecurity, desc: AppStrings.featureSecurityDesc),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width < 600 ? 1 : (width < 1024 ? 2 : 3);
    final isMobile = width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: 48,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: crossAxisCount == 1 ? 3 : 2,
        ),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final f = _features[index];
          return _FeatureCard(icon: f.icon, title: f.title, description: f.desc);
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
