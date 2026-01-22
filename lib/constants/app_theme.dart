import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // --- AYDINLIK TEMA ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background, // Bej

    // AppBar Teması
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
      elevation: 0,
    ),

    // Kart Teması
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Buton Teması
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    ),

    // Metin Teması (Varsayılan Siyah)
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.black87),
    ),
  );

  // --- KARANLIK TEMA ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary, // Kahverengi karanlıkta da güzel durur
    scaffoldBackgroundColor: AppColors.darkBackground, // Koyu Gri

    // AppBar Teması
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      iconTheme: IconThemeData(color: AppColors.white), // İkonlar beyaz olsun
      titleTextStyle: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
      elevation: 0,
    ),

    // Kart Teması
    cardTheme: CardThemeData(
      color: AppColors.darkSurface, // Kartlar koyu gri
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Buton Teması
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    ),

    // Metin Teması (Varsayılan Beyaz)
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.white),
    ),
  );
}