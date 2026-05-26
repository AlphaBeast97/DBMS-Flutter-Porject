import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color ink = Color(0xFF141414);
  static const Color cream = Color(0xFFF7F3ED);
  static const Color coral = Color(0xFFF26B4A);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color sky = Color(0xFF2D7BD1);
  static const Color clay = Color(0xFFB86B4B);

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.spaceGroteskTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: coral,
        secondary: teal,
        surface: cream,
        background: cream,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: cream,
      textTheme: textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return clay;
      case 'in progress':
        return sky;
      case 'ready':
        return teal;
      case 'completed':
        return teal;
      case 'cancelled':
        return Colors.grey;
      default:
        return coral;
    }
  }
}
