import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Paleta de Luxo "Midnight Gold"
  static const Color background = Color(0xFF121212); // Preto Quase Absoluto
  static const Color surface = Color(0xFF1E1E1E);    // Cinza Escuro para Cartões
  static const Color gold = Color(0xFFFFD700);       // Dourado Vibrante (Acentos)
  static const Color goldDark = Color(0xFFB8860B);   // Dourado Mais Escuro (para gradientes/sombras)

  static const Color textPrimary = Colors.white;     // Texto Principal (Branco)
  static const Color textSecondary = Color(0xFFB0B0B0); // Texto Secundário (Cinza Claro)

  static const Color error = Color(0xFFCF6679);      // Vermelho para Erros
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true, // Usa o design mais recente do Google
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background, // Fundo Preto
      primaryColor: AppColors.gold,

      // Configuração de Fontes Modernas (Google Fonts)
      textTheme: TextTheme(
        // Títulos Grandes (Ex: "Bem-vindo")
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
          letterSpacing: 1.2,
        ),
        // Títulos de Secção (Ex: "Os Nossos Serviços")
        titleLarge: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary
        ),
        // Texto Normal
        bodyMedium: GoogleFonts.lato(fontSize: 16, color: AppColors.textPrimary),
        // Texto Pequeno/Descrições
        bodySmall: GoogleFonts.lato(fontSize: 14, color: AppColors.textSecondary),
      ),

      // Estilo dos Botões Grandes (Como os das imagens)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.black, // Texto do botão preto para contraste máximo
          elevation: 8, // Sombra para dar destaque
          shadowColor: AppColors.gold.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Cantos arredondados modernos
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          textStyle: GoogleFonts.lato(
              fontWeight: FontWeight.w800, // Texto bem grosso e visível
              fontSize: 18
          ),
        ),
      ),

      // Estilo dos Campos de Texto (Inputs)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface, // Fundo cinza escuro
        contentPadding: const EdgeInsets.all(20), // Espaçamento interno grande
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        // Borda quando não está selecionado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.surface.withOpacity(0.5), width: 1),
        ),
        // Borda quando está selecionado (Dourada)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        // Ícones dentro dos inputs
        prefixIconColor: AppColors.gold,
      ),

      // Estilo da Barra Superior (AppBar)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.gold),
        titleTextStyle: GoogleFonts.playfairDisplay(
            color: AppColors.gold,
            fontSize: 24,
            fontWeight: FontWeight.bold
        ),
      ),

      // Estilo dos Ícones na Barra de Navegação Inferior
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}