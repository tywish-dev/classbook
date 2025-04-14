import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0F1125);
  static const Color primaryGreen = Color(0xFF2CDD93);
  static const Color secondary = Color(0xFF6C5DD3);
  static const Color darkGreen = Color(0xFF2D3047);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8C8CA3);
  static const Color darkGrey = Color(0xFF242535);

  static const List<Color> categoryColors = [
    Color(0xFF6C5DD3),
    Color(0xFFFFB800),
    Color(0xFF00B8D9),
    Color(0xFFFF5630),
    Color(0xFF2CDD93),
  ];

  static const List<Color> bookColors = [
    Color(0xFF6C5DD3),
    Color(0xFFFFB800),
    Color(0xFF00B8D9),
    Color(0xFFFF5630),
    Color(0xFF2CDD93),
  ];

  static const List<Color> authorColors = [
    Color(0xFF6C5DD3),
    Color(0xFFFFB800),
    Color(0xFF00B8D9),
    Color(0xFFFF5630),
    Color(0xFF2CDD93),
  ];
}

class AppTextStyles {
  static final TextStyle heading1 = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static final TextStyle heading2 = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static final TextStyle heading3 = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static TextStyle subtitle2 = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static final TextStyle subtitle1 = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textWhite,
  );

  static final TextStyle body = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textWhite,
  );

  static final TextStyle bodyBold = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static final TextStyle caption = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textGrey,
  );

  static TextStyle price = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryGreen,
  );

  static final TextStyle button = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
  );
}

class AppPaddings {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xlarge = 32.0;
}

class AppBorders {
  static final BorderRadius small = BorderRadius.circular(8.0);
  static final BorderRadius medium = BorderRadius.circular(12.0);
  static final BorderRadius large = BorderRadius.circular(16.0);
  static final BorderRadius circular = BorderRadius.circular(100.0);
}
