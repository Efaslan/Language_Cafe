import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  // Veritabanı anahtarı
  static const _themeKey = 'isDarkMode';

  @override
  ThemeMode build() {
    // 1. Başlangıçta hafızaya bak
    final prefs = ref.watch(sharedPreferencesProvider);
    final isDark = prefs.getBool(_themeKey) ?? false; // Varsayılan: Aydınlık (false)

    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;

    // 2. Değişikliği hafızaya kaydet
    ref.read(sharedPreferencesProvider).setBool(_themeKey, isDark);
  }
}
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);