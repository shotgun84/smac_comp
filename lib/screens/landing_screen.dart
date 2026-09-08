import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/familia_widgets.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onSkip;
  const LandingScreen({super.key, required this.onCreate, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 0),
            child: Column(
              children: [
                Text('Familia', style: displayCaveat(size: 64, color: const Color(0xFF2E6B4E))),
                const SizedBox(height: 10),
                Text(
                  'Find food every family member loves',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 308,
                        height: 308,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5ECDD),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.elliptical(178, 148),
                            topRight: Radius.elliptical(129, 169),
                            bottomLeft: Radius.elliptical(169, 139),
                            bottomRight: Radius.elliptical(139, 160),
                          ),
                        ),
                      ),
                      Container(
                        width: 264,
                        height: 264,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 7),
                          boxShadow: [
                            BoxShadow(color: AppColors.sageDark.withValues(alpha: 0.22), blurRadius: 44, offset: const Offset(0, 18)),
                          ],
                        ),
                        child: ClipOval(
                          child: NetImage(url: kLandingImage, fallback: kLandingFallback, width: 264, height: 264),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 22 + MediaQuery.of(context).padding.bottom),
          color: AppColors.phoneBg,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  child: const Text('Create your family'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.sageDark,
                    backgroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: AppColors.sage, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
