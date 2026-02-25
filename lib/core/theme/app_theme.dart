import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Vibrant & Premium Palette ──
  static const Color primaryGreen = Color(0xFF00C853);    // Vibrant Emerald
  static const Color secondaryGreen = Color(0xFF00E676);  // Light Emerald
  static const Color deepGreen = Color(0xFF1B5E20);       // Forest Green
  static const Color backgroundLight = Color(0xFFF8FAF9); // Crisp White/Grey
  static const Color surfaceCard = Colors.white;
  static const Color textMain = Color(0xFF1B5E20);        // Premium Forest Green Headings
  static const Color textSecondary = Color(0xFF333333);   // Grounded Dark Grey
  
  static const Color accentBlue = Color(0xFF0984E3);      // Sophisticated Blue
  static const Color glassBorder = Color(0x33FFFFFF);     // Glassmorphism border
  
  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: accentBlue,
        onSecondary: Colors.white,
        surface: backgroundLight,
        onSurface: textMain,
        error: const Color(0xFFD63031),
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: textMain),
        headlineMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: textMain),
        titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: textMain),
        titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: textMain),
        titleSmall: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: textMain),
        headlineSmall: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textMain),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, color: textMain),
        bodyMedium: GoogleFonts.outfit(fontSize: 14, color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textMain,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: textMain),
      ),
      cardTheme: CardThemeData(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.05),
        color: surfaceCard,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryGreen.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.outfit(color: textSecondary, fontWeight: FontWeight.w500),
        prefixIconColor: primaryGreen,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    const darkSurface = Color(0xFF121212);
    const darkText = Color(0xFFE0E0E0);

    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: accentBlue,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: darkText,
        error: const Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: darkSurface,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: darkText),
        headlineMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: darkText),
        titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: darkText),
        titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: darkText),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, color: darkText),
        bodyMedium: GoogleFonts.outfit(fontSize: 14, color: darkText.withOpacity(0.7)),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: darkText),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: GoogleFonts.outfit(color: darkText.withOpacity(0.7), fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.outfit(color: darkText.withOpacity(0.3)),
        prefixIconColor: primaryGreen,
      ),
    );
  }

  // Visual Utility for Glassmorphism
  static BoxDecoration glassDecoration({double blur = 10, double opacity = 0.1}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Gradient background for Premium screens
  static BoxDecoration premiumGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8F5E9), // Very Light Green
          Color(0xFFF1F8E9), // Light Lime
          Colors.white,
        ],
      ),
    );
  }
}
