// lib/core/iron_theme.dart
import 'package:flutter/material.dart';

class IronTheme {
  // --- Tactical Noir Color Palette ---
  // "High-End Monochrome" - Pure void background with white accents
  static const Color background = Colors.black;      // #000000 - The Void
  static const Color surface = Color(0xFF1A1A1A);    // Very dark grey for cards/dialogs
  static const Color surfaceHighlight = Color(0xFF2C2C2C); // Slightly lighter for emphasis
  static const Color primary = Colors.white;         // White - High-End Monochrome accent
  static const Color secondary = Color(0xFFFF6B35);  // Neon Orange (rarely used)
  static const Color danger = Color(0xFFCF6679);
  static const Color textHigh = Colors.white;        // Primary text
  static const Color textMedium = Color(0xFFAAAAAA); // Secondary text
  static const Color textLow = Color(0xFF666666);    // Dimmed text

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Pretendard',
      
      // 1. THE VOID - Pure Black Backgrounds
      scaffoldBackgroundColor: background,  // #000000
      canvasColor: background,              // #000000
      primaryColor: background,             // #000000
      
      // 2. Material 3 Color Scheme - Tactical Noir
      colorScheme: const ColorScheme.dark(
        primary: primary,                   // Electric Blue
        onPrimary: textHigh,
        secondary: secondary,
        onSecondary: textHigh,
        surface: surface,                   // Dark grey for dialogs
        onSurface: textHigh,
        surfaceContainerHigh: surfaceHighlight,
        error: danger,
        onError: textHigh,
        // Force black backgrounds
        surfaceContainerHighest: background,
        surfaceContainerLowest: background,
      ),

      // 3. Seamless AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: background,        // Pure black
        elevation: 0,                       // No shadow
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22, 
          fontWeight: FontWeight.bold, 
          color: textHigh,
        ),
        iconTheme: IconThemeData(color: textHigh),
      ),

      // 4. Bottom Navigation - Tactical Style
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,        // Pure black
        selectedItemColor: Colors.white,    // White - High-End Monochrome
        unselectedItemColor: textLow,       // Dimmed grey
        elevation: 0,                       // No shadow
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // 5. Cards - Very Dark Grey (visible against black)
      cardTheme: CardThemeData(
        color: surface,                     // #1A1A1A
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 6. Dialogs - Dark Grey (needs to stand out)
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,           // #1A1A1A
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),

      // 7. Date Picker Theme
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: surfaceHighlight,
        headerForegroundColor: textHigh,
        dayForegroundColor: WidgetStateProperty.all(textHigh),
        yearForegroundColor: WidgetStateProperty.all(textHigh),
        todayBackgroundColor: WidgetStateProperty.all(primary),
        todayForegroundColor: WidgetStateProperty.all(textHigh),
        yearOverlayColor: WidgetStateProperty.all(primary.withValues(alpha: 0.1)),
        dayOverlayColor: WidgetStateProperty.all(primary.withValues(alpha: 0.1)),
      ),

      // 8. Input Fields - Visible on black
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,                 // Dark grey
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4), // Sharp corners
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: textLow),
        labelStyle: const TextStyle(color: textMedium),
      ),

      // 9. Text Buttons (Dialog actions)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,         // Electric Blue
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // 10. Bottom Sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // 11. Text Theme - White on Black
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textHigh),
        bodyMedium: TextStyle(color: textHigh),
        bodySmall: TextStyle(color: textMedium),
        titleLarge: TextStyle(color: textHigh, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: textHigh, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textMedium),
      ),
    );
  }
}