import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.bgPrimary,
      
      colorScheme: const ColorScheme.dark(
        primary: Colors.white, 
        secondary: AppColors.accentOrange,
        // Note: 'background' is deprecated in Flutter 3.22+. Use 'surface' instead.
        // background: AppColors.bgPrimary, 
        surface: AppColors.bgSecondary,
        error: Colors.white, // Completely removes default red for errors
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),

      /// ✅ TEXT FIELD THEME (NO RED ANYWHERE)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        hintStyle: const TextStyle(color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        /// NORMAL BORDER
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),

        /// ENABLED
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),

        /// FOCUSED
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),

        /// 🔥 ERROR (NO RED)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),

        /// Error text style
        errorStyle: const TextStyle(color: Colors.white),
      ),

      /// ✅ CURSOR + TEXT SELECTION (NO RED)
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.white24,
        selectionHandleColor: Colors.white,
      ),

      /// ✅ ELEVATED BUTTON
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, 
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      dividerColor: AppColors.divider,
    );
  }
}