import 'package:flutter/material.dart';

/// Centralized color palette for the LearnMentor app.
///
/// All widgets should reference these tokens instead of hardcoded colors.
/// This makes future re-branding or dark-mode adjustments a single-file change.
abstract class AppColors {
  AppColors._();

  // ─── Primary Brand ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1565C0); // blue.shade800
  static const Color primaryLight = Color(0xFF1976D2); // blue.shade700
  static const Color primaryMid = Color(0xFF42A5F5); // blue.shade400
  static const Color primarySurface = Color(0xFFE3F2FD); // blue.shade50

  // ─── Gradient ─────────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF1565C0), // blue.shade800
    Color(0xFF1E88E5), // blue.shade600
  ];

  static const List<Color> heroGradient = [
    Color(0xFF1976D2), // blue.shade700
    Color(0xFF42A5F5), // blue.shade400
  ];

  // ─── Background / Surface ─────────────────────────────────────────────────
  static const Color background = Color(
    0xFFF5F8FF,
  ); // very light blue-tinted white
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // ─── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32); // green.shade800
  static const Color successLight = Color(0xFFE8F5E9); // green.shade50
  static const Color warning = Color(0xFFE65100); // deepOrange.shade900
  static const Color warningLight = Color(0xFFFFF3E0); // orange.shade50
  static const Color error = Color(0xFFC62828); // red.shade800
  static const Color errorLight = Color(0xFFFFEBEE); // red.shade50
  static const Color info = Color(0xFF0277BD); // lightBlue.shade800
  static const Color infoLight = Color(0xFFE1F5FE); // lightBlue.shade50

  // ─── Stat Card Accent Colors ──────────────────────────────────────────────
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color accentOrange = Color(0xFFF57C00);
  static const Color accentGreen = Color(0xFF388E3C);
  static const Color accentTeal = Color(0xFF00796B);
  static const Color accentPurple = Color(0xFF6A1B9A);
  static const Color accentIndigo = Color(0xFF283593);
  static const Color accentAmber = Color(0xFFF9A825);
  static const Color accentRed = Color(0xFFD32F2F);
  static const Color accentCyan = Color(0xFF00838F);
  static const Color accentDeepPurple = Color(0xFF4527A0);

  // ─── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0D1F3C); // very dark blue-black
  static const Color textSecondary = Color(0xFF546E7A); // blue-grey.shade600
  static const Color textMuted = Color(0xFF90A4AE); // blue-grey.shade300
  static const Color textOnPrimary = Colors.white;

  // ─── Border / Divider ─────────────────────────────────────────────────────
  static const Color border = Color(0xFFBBDEFB); // blue.shade100
  static const Color divider = Color(0xFFE3F2FD); // blue.shade50

  // ─── Shadow ──────────────────────────────────────────────────────────────
  static Color shadow = const Color(0xFF1976D2).withValues(alpha: 0.15);
  static Color shadowNeutral = const Color(0xFF000000).withValues(alpha: 0.06);

  // ─── Notification badge ───────────────────────────────────────────────────
  static const Color badge = Color(0xFFE53935); // red.shade600
}

/// Semantic spacing tokens — use these instead of const EdgeInsets everywhere.
abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Semantic radius tokens.
abstract class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;
}
