import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4141E7),
      secondary: const Color(0xFF11BB8D),
      primaryContainer: const Color(0xFFFFFFFF),
      onPrimaryContainer: const Color(0XFF09101D),
      secondaryContainer: const Color(0xFF23262B),
      onSecondaryContainer: const Color(0xFFFFFFFF),
      surface: const Color.fromRGBO(255, 255, 255, 1),
      error: const Color(0xFFDA1414),
    ),
    scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color.fromRGBO(246, 246, 246, 1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: Color.fromRGBO(9, 16, 29, 0.9)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(color: Color(0xFFDA1414)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size.fromHeight(50),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
    ),
  );
});
