import 'package:flutter/material.dart';

/// Premium color palette for the Smart Barcode Evaluator app
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Dark Theme Colors
  static const darkBackground = Color(0xFF1A1D29); // Deep navy
  static const darkSurface = Color(0xFF252936); // Charcoal
  static const darkSurfaceVariant = Color(0xFF2D3142);
  
  // Light Theme Colors
  static const lightBackground = Color(0xFFFAFAFA); // Clean white
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF5F5F5);
  
  // Primary & Accent Colors (same for both themes)
  static const primary = Color(0xFF00D9A3); // Health green
  static const primaryDark = Color(0xFF00B386);
  static const primaryLight = Color(0xFF33E3B5);
  
  static const secondary = Color(0xFFFFB800); // Premium gold
  static const secondaryDark = Color(0xFFE6A600);
  static const secondaryLight = Color(0xFFFFC733);
  
  // Status Colors
  static const error = Color(0xFFFF6B6B);
  static const success = Color(0xFF00D9A3);
  static const warning = Color(0xFFFFB800);
  static const info = Color(0xFF4A90E2);
  
  // Score Range Colors
  static const scoreExcellent = Color(0xFF00D9A3); // 71-100
  static const scoreGood = Color(0xFF7FD957); // 61-70
  static const scoreFair = Color(0xFFFFB800); // 41-60
  static const scorePoor = Color(0xFFFF8C42); // 31-40
  static const scoreBad = Color(0xFFFF6B6B); // 0-30
  
  // Text Colors
  static const textDark = Color(0xFFFFFFFF);
  static const textDarkSecondary = Color(0xFFB0B0B0);
  static const textDarkTertiary = Color(0xFF808080);
  
  static const textLight = Color(0xFF1A1D29);
  static const textLightSecondary = Color(0xFF6B6B6B);
  static const textLightTertiary = Color(0xFF9E9E9E);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const excellentGradient = LinearGradient(
    colors: [Color(0xFF00D9A3), Color(0xFF00B386)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const fairGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF8C42)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const badGradient = LinearGradient(
    colors: [Color(0xFFFF8C42), Color(0xFFFF6B6B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
