import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color primaryBlue = Color(0xFF3F6DB0);
  static const Color darkBlue = Color(0xFF274979);
  static const Color lightBlue = Color(0xFF6F8FC8);

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: primaryBlue,
      useMaterial3: true,
    );
  }
}
