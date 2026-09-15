import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Primary & Accent Tokens
  static const Color emeraldGreen = Color(0xFF0F5132);
  static const Color emeraldGreenLight = Color(0xFF198754);
  static const Color emeraldGreenDark = Color(0xFF0A3622);

  static const Color sandGold = Color(0xFFD4AF37);
  static const Color sandGoldLight = Color(0xFFE6CA65);
  static const Color sandGoldDark = Color(0xFFA38321);

  // Light Mode Surfaces
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F3F5);
  static const Color lightTextPrimary = Color(0xFF212529);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightBorder = Color(0xFFDEE2E6);

  // Dark Mode Surfaces
  static const Color darkBackground = Color(0xFF12181B);
  static const Color darkSurface = Color(0xFF1E262B);
  static const Color darkCard = Color(0xFF273138);
  static const Color darkTextPrimary = Color(0xFFF8F9FA);
  static const Color darkTextSecondary = Color(0xFFA0ABBA);
  static const Color darkBorder = Color(0xFF2F3C46);

  // Status Colors
  static const Color success = Color(0xFF198754);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFDC3545);
  static const Color info = Color(0xFF0D6EFD);
}
