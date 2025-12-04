import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Paleta de Luxo "Midnight Gold"
  static const Color background = Color(0xFF121212); // Preto Quase Absoluto
  static const Color surface = Color(0xFF1E1E1E);    // Cinza Escuro
  static const Color gold = Color(0xFFFFD700);       // Dourado Vibrante
  static const Color textPrimary = Colors.white;     // Branco
  static const Color textSecondary = Color(0xFFB0B0B0); // Cinza Claro
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.gold,
      
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.gold),
        bodyMedium: GoogleFonts.lato(fontSize: 16, color: AppColors.textPrimary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}