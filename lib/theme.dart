import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFE9E4DA);
  static const phoneBg = Color(0xFFFFFBF7);
  static const surface = Color(0xFFFFF8F5);
  static const cream = Color(0xFFFFF8F5);
  static const card = Colors.white;
  static const ink = Color(0xFF2F3D36);
  static const muted = Color(0xFF7A8B83);
  static const muted2 = Color(0xFFA9B8B1);
  static const line = Color(0xFFE7DDD3);
  static const sage = Color(0xFF5A7D6B);
  static const sageDark = Color(0xFF3E6B57);
  static const accentSoft = Color(0xFFDDEEDB);
  static const chipBg = Color(0xFFE4F0DF);
  static const mint = Color(0xFFCDE6C5);
  static const mintBorder = Color(0xFFA9CFA4);
  static const mintDeep = Color(0xFF5A7D6B);
  static const chipText = Color(0xFF2F4A3E);
  static const reqBrown = Color(0xFFB7791F);
  static const danger = Color(0xFF9B1C14);
  static const warnBg = Color(0xFFFFF0EE);
  static const warnBorder = Color(0xFFFFD9D6);
  static const inputBorder = Color(0xFFCBD8CF);
  static const starGreen = Color(0xFF3E6B57);
}

ThemeData familiaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sageDark,
      primary: AppColors.sageDark,
      surface: AppColors.cream,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sage,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}

TextStyle displayCaveat({double size = 64, Color color = AppColors.sageDark, FontWeight weight = FontWeight.w700}) {
  return GoogleFonts.caveat(fontSize: size, fontWeight: weight, color: color, height: 1.0);
}

TextStyle bodyInter({double size = 14, Color color = AppColors.ink, FontWeight weight = FontWeight.w500}) {
  return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
}
