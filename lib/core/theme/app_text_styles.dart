import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings (Sora)
  static TextStyle h1({Color color = AppColors.textPrimary}) => GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle h2({Color color = AppColors.textPrimary}) => GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle h3({Color color = AppColors.textPrimary}) => GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle h4({Color color = AppColors.textPrimary}) => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Body Text (DM Sans)
  static TextStyle bodyLarge({Color color = AppColors.textPrimary, double height = 1.5}) => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
        height: height,
      );

  static TextStyle bodyMedium({Color color = AppColors.textSecondary, double height = 1.4}) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
        height: height,
      );

  static TextStyle bodySmall({Color color = AppColors.textMuted, double height = 1.3}) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
        height: height,
      );

  // Action Text / Labels
  static TextStyle label({Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w600}) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: weight,
        color: color,
      );

  static TextStyle buttonText({Color color = Colors.white}) => GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
