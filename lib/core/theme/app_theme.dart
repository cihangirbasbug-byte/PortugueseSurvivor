import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: AppColors.background,

      colorSchemeSeed: AppColors.primary,

      textTheme: GoogleFonts.poppinsTextTheme(),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}