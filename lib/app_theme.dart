import 'package:flutter/material.dart';

class AppTheme {
  // تدرجات الأرجواني الملكي
  static const Color primaryPurple = Color(0xFF6A11CB); 
  static const Color accentPurple = Color(0xFF2575FC);
  static const Color deepBlack = Color(0xFF090909);
  static const Color surfaceDark = Color(0xFF161618);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: deepBlack,
      cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}