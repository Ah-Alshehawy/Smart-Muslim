import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static const String arabicFontFamily = 'Tajawal';
  static const String quranFontFamily = 'Amiri';
  static const String englishFontFamily = 'Inter';

  static TextStyle displayLarge(bool isDark) => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle titleLarge(bool isDark) => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle titleMedium(bool isDark) => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  static TextStyle caption(bool isDark) => TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.sandGoldLight : AppColors.emeraldGreen,
      );

  static TextStyle arabicText({
    double fontSize = 18,
    bool isDark = false,
    FontWeight fontWeight = FontWeight.normal,
  }) =>
      TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle quranText({double fontSize = 24, bool isDark = false}) => TextStyle(
        fontFamily: quranFontFamily,
        fontSize: fontSize,
        height: 1.8,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );
}
