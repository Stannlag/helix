import 'package:flutter/material.dart';

/// Helix Color Palette
/// DNA-inspired colors for the time tracking app
class AppColors {
  AppColors._();

  // Primary Colors - DNA Helix inspired
  static const Color primary = Color(0xFF4CAF50); // Growth green
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFF81C784);

  // Secondary Colors - Accent
  static const Color secondary = Color(0xFF2196F3); // Progress blue
  static const Color secondaryDark = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF64B5F6);

  // Tertiary - Helix accent
  static const Color tertiary = Color(0xFF9C27B0); // Creative purple
  static const Color tertiaryDark = Color(0xFF7B1FA2);
  static const Color tertiaryLight = Color(0xFFBA68C8);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Activity Colors (Customizable by users)
  static const List<Color> activityColors = [
    Color(0xFF4CAF50), // Green - Health/Exercise
    Color(0xFF2196F3), // Blue - Learning/Study
    Color(0xFFF44336), // Red - Work/Productivity
    Color(0xFF9C27B0), // Purple - Creative
    Color(0xFFFF9800), // Orange - Social
    Color(0xFF00BCD4), // Cyan - Relaxation
    Color(0xFFFFEB3B), // Yellow - Fun
    Color(0xFF795548), // Brown - Reading
    Color(0xFFE91E63), // Pink - Hobbies
    Color(0xFF607D8B), // Blue Grey - Other
  ];

  // Emoji Rating Colors
  static const Color emojiSad = Color(0xFFF44336); // 😞
  static const Color emojiNeutral = Color(0xFFFF9800); // 😐
  static const Color emojiHappy = Color(0xFFFDD835); // 😊
  static const Color emojiAmazing = Color(0xFF4CAF50); // 🤩
}
