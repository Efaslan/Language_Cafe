import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Temayı yöneten Notifier
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.light; // Varsayılan Aydınlık
  }

  // Modu değiştir
  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

// Global Provider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);