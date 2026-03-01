import 'dart:ui';

class AppColors {
  final Color primary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color sidebarBackground;
  final Color toolbarBackground;
  final Color surfaceSecondary;
  final Color hoverOverlay;
  final Color selectionHighlight;
  final Color shadowColor;
  final Color frostedGlassTint;
  final Color dividerSubtle;

  const AppColors({
    required this.primary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.sidebarBackground,
    required this.toolbarBackground,
    required this.surfaceSecondary,
    required this.hoverOverlay,
    required this.selectionHighlight,
    required this.shadowColor,
    required this.frostedGlassTint,
    required this.dividerSubtle,
  });

  // Predator (Default)
  static const predatorLight = AppColors(
    primary: Color(0xFFE67E22),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF8F9FA),
    textPrimary: Color(0xFF212529),
    textSecondary: Color(0xFF6C757D),
    border: Color(0xFFDEE2E6),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    error: Color(0xFFD32F2F),
    info: Color(0xFF0288D1),
    sidebarBackground: Color(0xFFF2F0ED),
    toolbarBackground: Color(0xFFFCFBFA),
    surfaceSecondary: Color(0xFFF0F1F3),
    hoverOverlay: Color(0x0FE67E22),
    selectionHighlight: Color(0x1FE67E22),
    shadowColor: Color(0x1A000000),
    frostedGlassTint: Color(0xB3FFFFFF),
    dividerSubtle: Color(0x1A000000),
  );

  static const predatorDark = AppColors(
    primary: Color(0xFFF39C12),
    background: Color(0xFF1A1A1A),
    surface: Color(0xFF2D2D2D),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFADB5BD),
    border: Color(0xFF404040),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    info: Color(0xFF29B6F6),
    sidebarBackground: Color(0xFF222222),
    toolbarBackground: Color(0xFF242424),
    surfaceSecondary: Color(0xFF353535),
    hoverOverlay: Color(0x0FF39C12),
    selectionHighlight: Color(0x1FF39C12),
    shadowColor: Color(0x40000000),
    frostedGlassTint: Color(0xB31A1A1A),
    dividerSubtle: Color(0x1AFFFFFF),
  );

  // Precision
  static const precisionLight = AppColors(
    primary: Color(0xFF0A5C5C),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF8FAFC),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    border: Color(0xFFE2E8F0),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    error: Color(0xFFD32F2F),
    info: Color(0xFF0288D1),
    sidebarBackground: Color(0xFFF0F4F4),
    toolbarBackground: Color(0xFFFAFCFC),
    surfaceSecondary: Color(0xFFEFF2F5),
    hoverOverlay: Color(0x0F0A5C5C),
    selectionHighlight: Color(0x1F0A5C5C),
    shadowColor: Color(0x1A000000),
    frostedGlassTint: Color(0xB3FFFFFF),
    dividerSubtle: Color(0x1A000000),
  );

  static const precisionDark = AppColors(
    primary: Color(0xFF14B8A6),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0xFF334155),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    info: Color(0xFF29B6F6),
    sidebarBackground: Color(0xFF162032),
    toolbarBackground: Color(0xFF182234),
    surfaceSecondary: Color(0xFF263448),
    hoverOverlay: Color(0x0F14B8A6),
    selectionHighlight: Color(0x1F14B8A6),
    shadowColor: Color(0x40000000),
    frostedGlassTint: Color(0xB30F172A),
    dividerSubtle: Color(0x1AFFFFFF),
  );

  // Strike
  static const strikeLight = AppColors(
    primary: Color(0xFFC2410C),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF9FAFB),
    textPrimary: Color(0xFF030712),
    textSecondary: Color(0xFF4B5563),
    border: Color(0xFFE5E7EB),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    error: Color(0xFFD32F2F),
    info: Color(0xFF0288D1),
    sidebarBackground: Color(0xFFF3F0EE),
    toolbarBackground: Color(0xFFFCFBFA),
    surfaceSecondary: Color(0xFFF1F2F4),
    hoverOverlay: Color(0x0FC2410C),
    selectionHighlight: Color(0x1FC2410C),
    shadowColor: Color(0x1A000000),
    frostedGlassTint: Color(0xB3FFFFFF),
    dividerSubtle: Color(0x1A000000),
  );

  static const strikeDark = AppColors(
    primary: Color(0xFFF97316),
    background: Color(0xFF030712),
    surface: Color(0xFF111827),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFF9CA3AF),
    border: Color(0xFF1F2937),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    info: Color(0xFF29B6F6),
    sidebarBackground: Color(0xFF0A0F1A),
    toolbarBackground: Color(0xFF0C1120),
    surfaceSecondary: Color(0xFF1A2236),
    hoverOverlay: Color(0x0FF97316),
    selectionHighlight: Color(0x1FF97316),
    shadowColor: Color(0x40000000),
    frostedGlassTint: Color(0xB3030712),
    dividerSubtle: Color(0x1AFFFFFF),
  );
}
