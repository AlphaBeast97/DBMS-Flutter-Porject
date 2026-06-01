/// Design system: color palette, Material 3 theme, and status helpers.
///
/// All color tokens are defined as static consts. The [lightTheme] getter
/// builds the app's full [ThemeData] using Google Fonts Space Grotesk.
/// Status helpers ([statusColor], [statusBg], [statusIcon], [statusLabel])
/// provide consistent rendering for repair job states across screens.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Brand palette ---
  static const Color coral = Color(0xFFF26B4A);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color sky = Color(0xFF2D7BD1);
  static const Color clay = Color(0xFFB86B4B);
  static const Color ink = Color(0xFF141414);
  static const Color cream = Color(0xFFF7F3ED);

  // --- Derived warm neutrals ---
  static const Color beige = Color(0xFFEFE7DA);
  static const Color line = Color(0x14141414); // rgba(20,20,20,0.08)
  static const Color line2 = Color(0x24141414); // rgba(20,20,20,0.14)
  static const Color muted = Color(0x8C141414); // rgba(20,20,20,0.55)
  static const Color faint = Color(0x61141414); // rgba(20,20,20,0.38)
  static const Color grey = Color(0xFF9A958C);
  static const Color white = Color(0xFFFFFFFF);
  static const String fontFamily = 'Space Grotesk';

  /// Full Material 3 light theme with coral primary, teal secondary,
  /// cream surface, and Space Grotesk text.
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.spaceGroteskTextTheme();
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: coral,
        secondary: teal,
        surface: cream,
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
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Returns the foreground color for a given job status.
  /// Used by [StatusBadge], [JobCard], and status icons.
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return clay;
      case 'in progress':
      case 'repairing':
        return sky;
      case 'ready':
        return teal;
      case 'completed':
      case 'delivered':
        return teal;
      case 'cancelled':
        return grey;
      default:
        return coral;
    }
  }

  /// Returns a translucent background tint for a given status.
  static Color statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0x1FB86B4B);
      case 'in progress':
      case 'repairing':
        return const Color(0x1F2D7BD1);
      case 'ready':
        return const Color(0x242A9D8F);
      case 'cancelled':
        return const Color(0x299A958C);
      case 'delivered':
      case 'completed':
        return const Color(0x242A9D8F);
      default:
        return const Color(0x1FF26B4A);
    }
  }

  /// Returns the Material icon for a given status.
  static IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'in progress':
      case 'repairing':
        return Icons.build;
      case 'ready':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'delivered':
      case 'completed':
        return Icons.local_shipping;
      default:
        return Icons.help_outline;
    }
  }

  /// Returns the human-readable label for a given status.
  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in progress':
      case 'repairing':
        return 'Repairing';
      case 'ready':
        return 'Ready';
      case 'cancelled':
        return 'Cancelled';
      case 'delivered':
      case 'completed':
        return 'Delivered';
      default:
        return status;
    }
  }
}
