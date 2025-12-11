import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  // Neutral palette inspired by logistics UI (light background, dark text)
  static const Color primary = Color(0xFF111827); // near-black
  static const Color accentBlue = Color(0xFF111827);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF3F4F6); // light gray background

  static ThemeData get lightTheme {
    final base = ThemeData(
      fontFamily: 'Roboto',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentBlue,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        secondary: primary,
      ),
      scaffoldBackgroundColor: surfaceAlt,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceAlt,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: surface,
      textTheme: base.textTheme.apply(
        bodyColor: primary,
        displayColor: primary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
