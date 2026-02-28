import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text(AppStrings.allCategories),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          for (final cat in categories) ...[
            FilterChip(
              label: Text(cat),
              selected: selected == cat,
              onSelected: (_) => onSelected(cat),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
