import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(AppColors colors) {
    return TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      displaySmall: GoogleFonts.geist(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      headlineMedium: GoogleFonts.geist(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      bodyLarge: GoogleFonts.geist(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      bodyMedium: GoogleFonts.geist(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      bodySmall: GoogleFonts.geist(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      labelSmall: GoogleFonts.geist(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colors.textSecondary,
      ),
      labelLarge: GoogleFonts.geist(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
    );
  }

  static TextStyle mono(AppColors colors, {double fontSize = 14}) {
    return GoogleFonts.geistMono(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: colors.textPrimary,
    );
  }
}
