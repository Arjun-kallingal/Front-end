import 'package:flutter/material.dart';

class AppColors {
  // ==================================================
  // BRAND / PRIMARY
  // ==================================================
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryRedDark = Color(0xFFC62828);
  static const Color accentOrange = Color(0xFFFF9800); // Upgrade / Premium

  // ==================================================
  // APP BACKGROUNDS
  // ==================================================
  static const Color bgPrimary = Color(0xFF0B0B0B);   // App background
  static const Color bgSecondary = Color(0xFF151515); // Section background

  // Gradient headers (Analytics, History, Profile)
  static const Color headerGradientStart = Color(0xFFB71C1C);
  static const Color headerGradientEnd = Color(0xFFE53935);

  // ==================================================
  // CARDS / CONTAINERS (Glass Dark)
  // ==================================================
  static const Color cardBg = Color(0xCC1A1A1A); // 80% opacity
  static const Color cardBorder = Color(0x332A2A2A);
  static const Color cardShadow = Color(0x99000000);

  // ==================================================
  // TEXT COLORS
  // ==================================================
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF7A7A7A);
  static const Color textHint = Color(0xFF5F5F5F);

  // ==================================================
  // STATUS COLORS (Income / Expense / Alerts)
  // ==================================================
  static const Color success = Color(0xFF2ECC71); // Income
  static const Color error = Color(0xFFE53935);   // Expense / Danger
  static const Color warning = Color(0xFFFF9800); // Locked / Alert
  static const Color info = Color(0xFF42A5F5);

  // ==================================================
  // TRANSACTIONS
  // ==================================================
  static const Color incomeIconBg = Color(0x332ECC71);
  static const Color expenseIconBg = Color(0x33E53935);
  static const Color incomeAmount = Color(0xFF2ECC71);
  static const Color expenseAmount = Color(0xFFE53935);
  static const Color dateLabel = Color(0xFF8A8A8A);

  // ==================================================
  // SEARCH & FILTERS
  // ==================================================
  static const Color searchBg = Color(0xFF1A1A1A);
  static const Color searchIcon = Color(0xFF8A8A8A);

  static const Color filterBg = Color(0xFF2A2A2A);
  static const Color filterSelectedBg = Color(0xFFE53935);
  static const Color filterSelectedText = Color(0xFFFFFFFF);
  static const Color filterText = Color(0xFFB0B0B0);

  // ==================================================
  // CHARTS (Analytics)
  // ==================================================
  static const Color chartIncome = Color(0xFF20C997);
  static const Color chartExpense = Color(0xFFE53935);
  static const Color chartBarBlue = Color(0xFF4285F4);
  static const Color chartGrid = Color(0xFF2A2A2A);
  static const Color chartAxis = Color(0xFF6F6F6F);

  // ==================================================
  // PROGRESS BARS / GOALS
  // ==================================================
  static const Color progressBg = Color(0xFF2A2A2A);
  static const Color progressRed = Color(0xFFE53935);
  static const Color progressGreen = Color(0xFF2ECC71);

  static const Color goalTagBg = Color(0xFF1E3A5F);
  static const Color goalTagText = Color(0xFF64B5F6);

  // ==================================================
  // PROFILE & SETTINGS
  // ==================================================
  static const Color profileAvatarBg = Color(0x33FFFFFF);
  static const Color listTileIconBg = Color(0x331A1A1A);
  static const Color listTileArrow = Color(0xFF8A8A8A);

  // Switches
  static const Color switchActive = Color(0xFFE53935);
  static const Color switchInactive = Color(0xFF4A4A4A);
  static const Color switchThumb = Color(0xFFFFFFFF);

  // Security / Danger
  static const Color dangerBg = Color(0xFF1A1A1A);
  static const Color dangerText = Color(0xFFE53935);

  // ==================================================
  // BOTTOM NAVIGATION
  // ==================================================
  static const Color navBg = Color(0xFF0F0F0F);
  static const Color navActive = Color(0xFFE53935);
  static const Color navInactive = Color(0xFF8A8A8A);

  // ==================================================
  // DIVIDERS / BORDERS
  // ==================================================
  static const Color divider = Color(0xFF1F1F1F);
  static const Color border = Color(0xFF2A2A2A);
}
