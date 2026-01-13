import 'package:flutter/material.dart';

/// App color palette for Kin.
///
/// Health ring colors indicate relationship status:
/// - [healthGreen]: Recently contacted (0-50% of cadence elapsed)
/// - [healthYellow]: Approaching due date (50-100% of cadence elapsed)
/// - [healthRed]: Overdue (>100% of cadence elapsed)
abstract final class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6B4EE6);
  static const Color primaryLight = Color(0xFF9D8AEF);
  static const Color primaryDark = Color(0xFF4A35A3);

  // Health ring colors (from spec)
  static const Color healthGreen = Color(0xFF98D4A0); // Mint green
  static const Color healthYellow = Color(0xFFF5E6A3); // Cream yellow
  static const Color healthRed = Color(0xFFF5A3A3); // Rose red

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // Circle tag colors (default palette)
  static const List<Color> circleColors = [
    Color(0xFFE57373), // Red
    Color(0xFFFFB74D), // Orange
    Color(0xFFFFF176), // Yellow
    Color(0xFFAED581), // Light Green
    Color(0xFF4DB6AC), // Teal
    Color(0xFF64B5F6), // Blue
    Color(0xFF9575CD), // Purple
    Color(0xFFF06292), // Pink
  ];
}
