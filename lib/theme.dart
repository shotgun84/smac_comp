import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // New identity: deep rust, clay, warm parchment, moss whisper.
  static const rust = Color(0xFF9A4826);
  static const rustDark = Color(0xFF7A351D);
  static const rustDeep = Color(0xFF5E2814);
  static const clay = Color(0xFFC97C48);
  static const claySoft = Color(0xFFF3DCC0);
  static const clayLine = Color(0xFFE0B88A);
  static const parchment = Color(0xFFF6ECDC);
  static const parchmentDeep = Color(0xFFEEDCBE);
  static const creamCard = Color(0xFFFFFBF2);
  static const navBrown = Color(0xFF2B1A12);
  static const ink = Color(0xFF2E1B12);
  static const muted = Color(0xFF8A6F5C);
  static const muted2 = Color(0xFFB89F86);
  static const line = Color(0xFFE5CFAE);
  static const moss = Color(0xFF6B7A4E);
  static const mossSoft = Color(0xFFE4E6D2);

  // Back-compat aliases so older call sites keep compiling.
  static const bg = parchment;
  static const phoneBg = parchment;
  static const surface = creamCard;
  static const cream = parchment;
  static const card = creamCard;
  static const sage = rust;
  static const sageDark = rust;
  static const accentSoft = claySoft;
  static const chipBg = claySoft;
  static const mint = claySoft;
  static const mintBorder = clayLine;
  static const mintDeep = rust;
  static const chipText = ink;
  static const reqBrown = rust;
  static const danger = Color(0xFF9B1C14);
  static const warnBg = Color(0xFFFFF0EE);
  static const warnBorder = Color(0xFFFFD9D6);
  static const inputBorder = line;
  static const starGreen = rust;
}

ThemeData familiaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.parchment,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.rust,
      primary: AppColors.rust,
      surface: AppColors.parchment,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.workSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.rust,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.clay, width: 2),
      ),
    ),
  );
}

/// Wonky/italic headline — Fraunces does the talking.
TextStyle displayFraunces({
  double size = 34,
  Color color = Colors.white,
  bool italic = true,
  FontWeight weight = FontWeight.w700,
}) {
  return GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: weight,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: color,
    height: 1.02,
    letterSpacing: -0.5,
  );
}

/// Calm upright labels — same family, no italics.
TextStyle labelFraunces({double size = 17, Color color = AppColors.ink}) {
  return GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    color: color,
    height: 1.15,
    letterSpacing: -0.2,
  );
}

TextStyle bodyWork({double size = 14, Color color = AppColors.ink, FontWeight weight = FontWeight.w500}) {
  return GoogleFonts.workSans(fontSize: size, fontWeight: weight, color: color, height: 1.45);
}

// Back-compat: old names now resolve to the new pairing.
TextStyle displayCaveat({double size = 64, Color color = AppColors.rust, FontWeight weight = FontWeight.w700}) {
  return displayFraunces(size: size, color: color, italic: true, weight: weight);
}

TextStyle bodyInter({double size = 14, Color color = AppColors.ink, FontWeight weight = FontWeight.w500}) {
  return bodyWork(size: size, color: color, weight: weight);
}

/// Single diagonal cut on the bottom-right — the ticket-clip.
/// Used on cards, members box, filter button and primary buttons.
class TicketClipper extends CustomClipper<Path> {
  final double cut;
  const TicketClipper({this.cut = 14});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final c = cut.clamp(0, h / 2).toDouble();
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - c)
      ..lineTo(w - c, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(TicketClipper old) => old.cut != cut;
}

class Ticketed extends StatelessWidget {
  final Widget child;
  final double cut;
  const Ticketed({super.key, required this.child, this.cut = 14});

  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: TicketClipper(cut: cut), child: child);
  }
}
