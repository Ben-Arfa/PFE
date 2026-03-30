// lib/core/theme_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider._();
  static final instance = ThemeProvider._();
  static const _key = 'kiwo_dark_mode';

  bool _isDark = false;
  bool get isDark => _isDark;

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get stream => _controller.stream;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? false;
    _controller.add(_isDark);
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    _controller.add(_isDark);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
  }

  // ── Couleurs contextuelles ────────────────────────────────────────
  Color get bgColor =>
      _isDark ? const Color(0xFF121212) : const Color(0xFFFFF8ED);
  Color get surfaceColor => _isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get cardColor => _isDark ? const Color(0xFF252525) : Colors.white;
  Color get headerColor => _isDark ? const Color(0xFF1A2E14) : Colors.white;
  Color get navColor => _isDark ? const Color(0xFF1A2E14) : Colors.white;
  Color get textColor =>
      _isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1C1C1A);
  Color get mutedColor =>
      _isDark ? const Color(0xFF9E9E9E) : const Color(0xFF7A7060);
  Color get borderColor =>
      _isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E2D4);
  Color get navTextInactive =>
      _isDark ? const Color(0xFF9E9E9E) : const Color(0xFF7A7060);
  Color get inputFill => _isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get dialogBg =>
      _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFF8ED);

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFF8ED),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4B7B28),
      brightness: Brightness.light,
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4B7B28),
      brightness: Brightness.dark,
    ),
    cardColor: const Color(0xFF1E1E1E),
  );
}
