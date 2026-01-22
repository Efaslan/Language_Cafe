import 'package:flutter/material.dart';

class AppColors {
  // main colors
  static const Color primary = Colors.brown;
  static const Color brownShade50 = Color(0xFFEFEBE9);
  static const Color brownShade100 = Color(0xFFD7CCC8);
  static const Color brownShade200 = Color(0xFFBCAAA4);

  static const Color background = Color(0xFFF5F5DC); // Bej
  static const Color transparent = Colors.transparent;

  static const Color white = Colors.white;
  static const Color white70 = Color(0xB3FFFFFF); // opacity %70 white
  static const Color softWhite = Color(0xFFFCFCFC); // setting sheet background

  static const Color black = Colors.black;
  static const Color black26 = Color(0x42000000); // opacity %26 black
  static const Color black87   = Color(0xDD000000);

  static const Color grey = Colors.grey;
  static const Color greyShade200 = Color(0xFFEEEEEE);
  static const Color greyShade300 = Color(0xFFE0E0E0);
  static const Color greyShade600 = Color(0xFF757575);

  static const Color redAccent = Colors.redAccent;
  static const Color redShade100 = Color(0xFFFFCDD2);

  static const Color orangeShade100 = Color(0xFFFFE0B2);
  static const Color blueShade100 = Color(0xFFBBDEFB);
  static const Color greenShade100 = Color(0xFFC8E6C9);
  // status colors
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color pending = Colors.orange;

  // Dark Mode
  static const Color darkBackground = Color(0xFF1E1E1E); // Koyu Gri/Siyah
  static const Color darkSurface = Color(0xFF2C2C2C); // Kartlar için koyu gri
  static const Color textPrimaryLight = Colors.black87; // Aydınlık modda yazı
  static const Color textPrimaryDark = Colors.white;    // Karanlık modda yazı
}