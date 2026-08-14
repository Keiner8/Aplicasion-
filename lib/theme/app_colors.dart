import 'package:flutter/material.dart';

/// Paleta de colores oficial de CleanClip.
class AppColors {
  // Colores base
  static const Color background = Color(0xFF0F111A);
  static const Color surface = Color(0xFF1A1D2E);
  static const Color surfaceLight = Color(0xFF252842);
  static const Color card = Color(0xFF1E2133);

  // Colores primarios morados
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFFA855F7);
  static const Color primaryLight = Color(0xFFBB86FC);

  // Texto
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B3C1);
  static const Color textHint = Color(0xFF6B7280);

  // Estado
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Bordes y divisores
  static const Color border = Color(0xFF2D3148);
  static const Color borderLight = Color(0xFF3D4160);

  // Glassmorphism
  static Color glassBackground = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFF9D50FB), Color(0xFF6E3AED)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F111A), Color(0xFF1A1D2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2133), Color(0xFF252842)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0F111A), Color(0xFF1E1040), Color(0xFF0F111A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
