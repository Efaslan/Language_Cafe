import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';

class LocaleNotifier extends Notifier<Locale> {
  // Veritabanı anahtarı
  static const _localeKey = 'languageCode';

  @override
  Locale build() {
    // 1. Başlangıçta hafızaya bak
    final prefs = ref.watch(sharedPreferencesProvider);
    final languageCode = prefs.getString(_localeKey) ?? 'tr'; // Varsayılan: Türkçe

    return Locale(languageCode);
  }

  void setLocale(Locale locale) {
    if (!['tr', 'en'].contains(locale.languageCode)) return;

    state = locale;

    // 2. Değişikliği hafızaya kaydet
    ref.read(sharedPreferencesProvider).setString(_localeKey, locale.languageCode);
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
    setLocale(newLocale);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);