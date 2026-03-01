import 'package:flutter/painting.dart';

import '../constants/app_spacing.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(AppColors colors) => [
        BoxShadow(
          color: colors.shadowColor,
          blurRadius: AppSpacing.shadowBlurCard,
          offset: const Offset(0, AppSpacing.shadowOffsetCard),
        ),
      ];

  static List<BoxShadow> elevated(AppColors colors) => [
        BoxShadow(
          color: colors.shadowColor,
          blurRadius: AppSpacing.shadowBlurElevated,
          offset: const Offset(0, AppSpacing.shadowOffsetElevated),
        ),
      ];

  static List<BoxShadow> dialog(AppColors colors) => [
        BoxShadow(
          color: colors.shadowColor,
          blurRadius: AppSpacing.shadowBlurDialog,
          offset: const Offset(0, AppSpacing.shadowOffsetDialog),
        ),
      ];
}
