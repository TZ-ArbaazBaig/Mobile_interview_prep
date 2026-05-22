import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgPrimary     = Color(0xFF0A0A0F);   // Near-black
  static const Color bgSecondary   = Color(0xFF12121A);   // Card background
  static const Color bgTertiary    = Color(0xFF1A1A26);   // Input fields

  // Violet Accent
  static const Color violet        = Color(0xFF7C3AED);   // Primary accent
  static const Color violetLight   = Color(0xFF9F67FF);   // Hover/active
  static const Color violetDim     = Color(0xFF3D1F7A);   // Muted violet

  // Text
  static const Color textPrimary   = Color(0xFFF1F0FF);
  static const Color textSecondary = Color(0xFF9B97B3);
  static const Color textMuted     = Color(0xFF5C5875);

  // Status
  static const Color success       = Color(0xFF22C55E);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color error         = Color(0xFFEF4444);
  static const Color info          = Color(0xFF3B82F6);

  // Border
  static const Color border        = Color(0xFF2A2840);
  static const Color borderActive  = Color(0xFF7C3AED);

  // Backwards compatibility aliases
  static const Color obsidianBg = bgPrimary;
  static const Color charcoalCard = bgSecondary;
  static const Color borderDark = border;
  static const Color violetPrimary = violet;
  static const Color violetSecondary = violet;
  static const Color violetAccent = violetLight;
  static const Color violetGlow = violetLight;
}
