import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;

  static Color get surfaceVariant => Colors.grey.withOpacity(0.15);


  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFFA29BFE);

  static const Color foodAccent = Color(0xFFFF7675);
  static const Color sportAccent = Color(0xFF0984E3);

  static const Color textDark = Color(0xFF2D3436);
  static const Color textGray = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFFF4757);


  static BoxShadow get shadowLow => BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 15,
    offset: const Offset(0, 5),
  );

  static BoxShadow get shadowMedium => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 15,
    offset: const Offset(0, 5),
  );
}

class AppTextStyles {
  static TextStyle get header => GoogleFonts.poppins(
      fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark
  );

  static TextStyle get subHeader => GoogleFonts.poppins(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark
  );

  static TextStyle get body => GoogleFonts.poppins(
      fontSize: 14, color: AppColors.textGray
  );

  static TextStyle get input => GoogleFonts.poppins(
      fontSize: 16, color: AppColors.textDark, fontWeight: FontWeight.normal
  );

  static TextStyle get label => GoogleFonts.poppins(
      fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textGray
  );

  static TextStyle get buttonText => GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white
  );
}
