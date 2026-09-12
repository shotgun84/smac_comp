import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/familia_widgets.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onSignIn;
  final VoidCallback onSkip;
  const LandingScreen({super.key, required this.onCreate, required this.onSignIn, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 44, 28, 0),
            child: Column(
              children: [
                Text('Familia',
                    style: displayFraunces(size: 68, color: AppColors.rust, italic: true)),
                const SizedBox(height: 8),
                Text(
                  'Find food every family member loves',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppColors.ink, height: 1.5),
                ),
                const SizedBox(height: 12),
                const HandDivider(),
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
                          color: AppColors.parchmentDeep,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.elliptical(178, 148),
                            topRight: Radius.elliptical(129, 169),
                            bottomLeft: Radius.elliptical(169, 139),
                            bottomRight: Radius.elliptical(139, 160),
                          ),
                        ),
                      ),
                      Ticketed(
                        cut: 26,
                        child: Container(
                          width: 264,
                          height: 264,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.creamCard, width: 7),
                            boxShadow: [
                              BoxShadow(color: AppColors.rust.withValues(alpha: 0.22), blurRadius: 44, offset: const Offset(0, 18)),
                            ],
                          ),
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
          padding: EdgeInsets.fromLTRB(22, 16, 22, 22 + MediaQuery.of(context).padding.bottom),
          color: AppColors.parchment,
          child: Column(
            children: [
              PrimaryButton(label: 'Create your family', onTap: onCreate),
              const SizedBox(height: 12),
              Ticketed(
                cut: 12,
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: AppColors.claySoft,
                    child: InkWell(
                      onTap: onSignIn,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 54),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.clay),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login, size: 18, color: AppColors.rust),
                            const SizedBox(width: 8),
                            Text('Sign in',
                                style: GoogleFonts.workSans(
                                    fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.rust)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rust,
                    backgroundColor: AppColors.creamCard,
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: AppColors.rust, width: 1.5),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    textStyle: GoogleFonts.workSans(fontWeight: FontWeight.w700, fontSize: 14.5),
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
