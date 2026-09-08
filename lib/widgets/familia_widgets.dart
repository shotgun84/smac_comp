import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08 * 11,
        color: AppColors.muted,
      ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const WhiteCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      padding: padding,
      child: child,
    );
  }
}

class FamiliaInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final TextInputType keyboard;
  final ValueChanged<String>? onChanged;
  const FamiliaInput({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLength = 100,
    this.keyboard = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.muted2, fontSize: 14.5),
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.sageDark, width: 1.5),
        ),
      ),
      style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppColors.ink),
    );
  }
}

class FamiliaArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const FamiliaArea({super.key, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      minLines: 2,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.muted2, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.sageDark, width: 1.5),
        ),
      ),
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool mintStyle;
  final IconData? icon;
  const PrimaryButton({super.key, required this.label, required this.onTap, this.mintStyle = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: mintStyle ? AppColors.mint : AppColors.sageDark,
          foregroundColor: mintStyle ? AppColors.chipText : Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: mintStyle ? AppColors.mintBorder : AppColors.sageDark),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 8)],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const GhostButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sageDark,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.sage, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        child: Text(label),
      ),
    );
  }
}

class SelectChip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback tap;
  final Color onBg;
  const SelectChip({super.key, required this.label, required this.on, required this.tap, this.onBg = AppColors.sageDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: on ? onBg : AppColors.mint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: on ? onBg : AppColors.mintBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: on ? Colors.white : AppColors.chipText,
          ),
        ),
      ),
    );
  }
}

class MiniTag extends StatelessWidget {
  final String label;
  final bool dark;
  const MiniTag(this.label, {super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? AppColors.sageDark : AppColors.mint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: dark ? AppColors.sageDark : AppColors.mintBorder),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: dark ? Colors.white : AppColors.chipText,
        ),
      ),
    );
  }
}

class StarRow extends StatelessWidget {
  final int value;
  final ValueChanged<int> onPick;
  const StarRow({super.key, required this.value, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final n = i + 1;
        final on = value >= n;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: GestureDetector(
            onTap: () => onPick(n),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: on ? AppColors.mint : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: on ? AppColors.sageDark : AppColors.inputBorder, width: 1.5),
              ),
              child: Icon(Icons.star, size: 14, color: on ? AppColors.sageDark : AppColors.inputBorder),
            ),
          ),
        );
      }),
    );
  }
}

class FamiliaBottomNav extends StatelessWidget {
  final String current;
  final ValueChanged<String> onNav;
  const FamiliaBottomNav({super.key, required this.current, required this.onNav});

  Widget item(BuildContext context, String key, IconData icon, String label) {
    final on = current == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onNav(key),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: on ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: on ? Colors.white : Colors.white.withValues(alpha: 0.85)),
              const SizedBox(height: 3),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.05 * 9,
                  color: on ? Colors.white : Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiOn = current == 'ai';
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
      ),
      padding: EdgeInsets.fromLTRB(10, 8, 10, 8 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          item(context, 'home', Icons.explore_outlined, 'Discover'),
          Expanded(
            child: GestureDetector(
              onTap: () => onNav('ai'),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: aiOn ? Colors.white.withValues(alpha: 0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: aiOn ? Colors.white : Colors.white.withValues(alpha: 0.18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Icon(Icons.smart_toy_outlined,
                          size: 13, color: aiOn ? AppColors.sageDark : Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text('AI',
                        style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.45,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          item(context, 'reviews', Icons.star_outline, 'Reviews'),
          item(context, 'family', Icons.group_outlined, 'Family'),
        ],
      ),
    );
  }
}

Future<void> showFamiliaSheet(BuildContext context, String title, Widget body, {Widget? foot}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Row(
                children: [
                  Expanded(
                      child: Text(title,
                          style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink))),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: const Icon(Icons.close, size: 16, color: AppColors.sageDark),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF0EDE9)),
            Expanded(child: SingleChildScrollView(controller: ctrl, padding: const EdgeInsets.all(18), child: body)),
            if (foot != null)
              Container(
                padding: EdgeInsets.fromLTRB(18, 14, 18, 14 + MediaQuery.of(ctx).padding.bottom),
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFF0EDE9))), color: Colors.white),
                child: foot,
              ),
          ],
        ),
      ),
    ),
  );
}

class NetImage extends StatelessWidget {
  final String url;
  final String fallback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? radius;
  const NetImage({super.key, required this.url, required this.fallback, this.width, this.height, this.fit = BoxFit.cover, this.radius});

  @override
  Widget build(BuildContext context) {
    Widget img(String u) => Image.network(
          u,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (c, child, p) =>
              p == null ? child : Container(width: width, height: height, color: const Color(0xFFECE9E6)),
          errorBuilder: (c, e, s) {
            if (u == fallback) {
              return Container(width: width, height: height, color: const Color(0xFFECE9E6));
            }
            return img(fallback);
          },
        );
    final child = img(url);
    if (radius != null) return ClipRRect(borderRadius: radius!, child: child);
    return child;
  }
}
