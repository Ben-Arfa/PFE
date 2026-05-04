// lib/core/app_colors.dart
//
// Palette KIWO — Blanc & Vert (mode clair)
// + helpers pour le mode sombre

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Mode clair ───────────────────────────────────────────────────
  static const green = Color(0xFF4B7B28);
  static const greenLight = Color(0xFF6A9E40);
  static const greenFaint = Color(0xFFEEF4E8);
  static const dark = Color(0xFF1C1C1A);
  static const muted = Color(0xFF7A7060);
  static const cream = Color(0xFFFFF8ED);
  static const surface = Color(0xFFFFFFFF);
  static const beetRed = Color(0xFFAB1717);
  static const amber = Color(0xFFB87333);
  static const blue = Color(0xFF5B8FA8);

  // Alias rétrocompatibilité
  static const orange = green;
  static const yellow = greenFaint;
  static const pink = greenFaint;

  // ── Mode sombre ──────────────────────────────────────────────────
  static const darkBg = Color(0xFF121212); // fond principal
  static const darkSurface = Color(0xFF1E1E1E); // cartes, formulaires
  static const darkCard = Color(0xFF252525); // cartes capteurs
  static const darkHeader = Color(0xFF1A2E14); // header/nav vert foncé
  static const darkBorder = Color(0xFF2A2A2A); // bordures
  static const darkText = Color(0xFFF0F0F0); // texte principal
  static const darkMuted = Color(0xFF9E9E9E); // texte secondaire

  // ── Helper contextuel ────────────────────────────────────────────
  // Retourne la bonne couleur selon le thème actuel
  static Color bg(bool isDark) => isDark ? darkBg : cream;
  static Color card(bool isDark) => isDark ? darkCard : surface;
  static Color header(bool isDark) => isDark ? darkHeader : surface;
  static Color text(bool isDark) => isDark ? darkText : dark;
  static Color textMuted(bool isDark) => isDark ? darkMuted : muted;
  static Color border(bool isDark) =>
      isDark ? darkBorder : const Color(0xFFE8E2D4);
}

// Compatibility helper: some codebase uses `.withValues(alpha: ...)`.
extension ColorWithValuesExtension on Color {
  Color withValues({double alpha = 1.0}) => withOpacity(alpha);
}
