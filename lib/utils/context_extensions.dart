import 'package:flutter/material.dart';
import 'package:language_cafe/l10n/app_localizations.dart';
import '../constants/app_colors.dart';

extension ThemeContext on BuildContext {
  /// O anki tema Karanlık mod mu?
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Temaya uygun arka plan rengi
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Temaya uygun ana metin rengi (Karanlıkta Beyaz, Aydınlıkta Kahve)
  Color get appTextColor => isDark ? Colors.white : AppColors.primary;

  /// Kullanım: context.l10n.welcomeTitle
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}