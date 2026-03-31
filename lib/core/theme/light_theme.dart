import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: Colors.white,

      colorScheme: const ColorScheme.light(
        primary: Colors.black, 
        secondary: AppColors.accentOrange,
        // Note: 'background' is deprecated in Flutter 3.22+. Use 'surface' instead.
        // background: Colors.white,
        surface: Colors.white,
        error: Colors.black, // 🔥 NO RED
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),

      /// ✅ TEXT FIELD THEME (NO RED ANYWHERE)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        /// NORMAL BORDER
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),

        /// ENABLED
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),

        /// FOCUSED
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),

        /// 🔥 ERROR (NO RED)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),

        /// OPTIONAL: remove red error text style
        errorStyle: const TextStyle(color: Colors.black),
      ),

      /// ✅ CURSOR + TEXT SELECTION (NO RED)
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionColor: Color(0xFFBDBDBD),
        selectionHandleColor: Colors.black,
      ),

      /// ✅ ELEVATED BUTTON
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, 
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      dividerColor: const Color(0xFFE5E5E5),
    );
  }
}