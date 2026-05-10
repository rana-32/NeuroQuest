import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    primaryColor: const Color(0xFF4FC3F7),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.lightBlue,
      accentColor: const Color(0xFFFFB74D),
      backgroundColor: const Color(0xFFFFF8E1),
      errorColor: Colors.redAccent,
      brightness: Brightness.light,
    ).copyWith(
      secondary: const Color(0xFFFFB74D),
      tertiary: const Color(0xFF81C784),
      error: Colors.redAccent,
    ),
    textTheme: GoogleFonts.baloo2TextTheme().copyWith(
      headlineLarge: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyMedium: const TextStyle(fontSize: 16, color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4FC3F7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4FC3F7),
        side: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      labelStyle: const TextStyle(color: Colors.black54),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF4FC3F7), size: 28),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4FC3F7),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    useMaterial3: true,
  );

  // Dark theme - optional
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF202020),
    primaryColor: const Color(0xFF4FC3F7),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.lightBlue,
      accentColor: const Color(0xFFFFB74D),
      backgroundColor: const Color(0xFF202020),
      errorColor: Colors.redAccent,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: const Color(0xFFFFB74D),
      tertiary: const Color(0xFF81C784),
      error: Colors.redAccent,
    ),
    textTheme: GoogleFonts.baloo2TextTheme().copyWith(
      headlineLarge: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyMedium: const TextStyle(fontSize: 16, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4FC3F7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4FC3F7),
        side: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF303030),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF303030),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF4FC3F7), size: 28),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4FC3F7),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    useMaterial3: true,
  );
}
