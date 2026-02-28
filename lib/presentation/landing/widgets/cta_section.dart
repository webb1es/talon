import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class CtaSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback? onViewOnePager;

  const CtaSection({super.key, required this.onGetStarted, this.onViewOnePager});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: 64,
      ),
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Column(
        children: [
          Text(
            AppStrings.ctaHeadline,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              AppStrings.ctaSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
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
              if (onViewOnePager != null)
                Semantics(
                  label: AppStrings.onePager,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text(AppStrings.onePager),
                    onPressed: onViewOnePager,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.tagline,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
