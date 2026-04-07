import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores — cielo nocturno dominicano 🇩🇴
  static const Color darkSpace    = Color(0xFF0A0E1A); // Fondo principal
  static const Color deepBlue     = Color(0xFF0D1B3E); // Fondo cards
  static const Color nebulaPurple = Color(0xFF2D1B69); // Acentos
  static const Color starGold     = Color(0xFFFFD700); // CTA / estrellas
  static const Color moonWhite    = Color(0xFFE8EAF6); // Texto principal
  static const Color cosmicGrey   = Color(0xFF546E7A); // Texto secundario
  static const Color auroraGreen  = Color(0xFF00E676); // Éxito / confirmación
  static const Color meteorRed    = Color(0xFFFF5252); // Peligro / borrar

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkSpace,
    colorScheme: const ColorScheme.dark(
      primary:   starGold,
      secondary: nebulaPurple,
      surface:   deepBlue,
      error:     meteorRed,
      onPrimary: darkSpace,
      onSurface: moonWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSpace,
      foregroundColor: moonWhite,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: deepBlue,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: nebulaPurple.withValues(alpha: 0.3)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: starGold,
      foregroundColor: darkSpace,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: deepBlue,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: nebulaPurple.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: nebulaPurple.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: starGold),
      ),
      labelStyle: const TextStyle(color: cosmicGrey),
    ),
  );
}