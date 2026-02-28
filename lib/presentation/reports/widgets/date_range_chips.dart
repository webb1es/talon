import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class DateRangeChips extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final ValueChanged<(DateTime, DateTime)> onChanged;

  const DateRangeChips({
    super.key,
    required this.from,
    required this.to,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = from == today && to == today;
    final is7 = from == today.subtract(const Duration(days: 6)) && to == today;
    final is30 = from == today.subtract(const Duration(days: 29)) && to == today;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text(AppStrings.today),
            selected: isToday,
            onSelected: (_) => onChanged((today, today)),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text(AppStrings.last7Days),
            selected: is7,
            onSelected: (_) => onChanged((
              today.subtract(const Duration(days: 6)),
              today,
            )),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text(AppStrings.last30Days),
            selected: is30,
            onSelected: (_) => onChanged((
              today.subtract(const Duration(days: 29)),
              today,
            )),
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.date_range, size: 18),
            label: const Text(AppStrings.customRange),
            onPressed: () => _pickRange(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: from, end: to),
      helpText: AppStrings.selectDateRange,
    );
    if (picked != null) {
      onChanged((picked.start, picked.end));
    }
  }
}
