import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class PageBanner extends StatelessWidget {
  final String title;
  final double titleSize;
  final Widget? subtitle;
  final Widget? titleLeading;
  final Widget? bottom;
  final bool italicTitle;
  const PageBanner({
    super.key,
    required this.title,
    this.titleSize = 32,
    this.subtitle,
    this.titleLeading,
    this.bottom,
    this.italicTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rust,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleLeading != null) ...[titleLeading!, const SizedBox(width: 9)],
              Expanded(
                child: Text(
                  title,
                  style: displayFraunces(size: titleSize, color: Colors.white, italic: italicTitle),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[const SizedBox(height: 8), subtitle!],
          if (bottom != null) ...[const SizedBox(height: 16), bottom!],
        ],
      ),
    );
  }
}

TextStyle bannerSub() => GoogleFonts.workSans(
    fontSize: 13.5, color: Colors.white.withValues(alpha: 0.9), height: 1.5, fontWeight: FontWeight.w500);

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: labelFraunces(size: 17));
  }
}

class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool sharp;
  final Color? color;
  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.sharp = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final body = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.creamCard,
        borderRadius: sharp ? BorderRadius.circular(8) : BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      padding: padding,
      child: child,
    );
    if (sharp) return body;
    return Ticketed(cut: 16, child: body);
  }
}

/// Tinted variant — breaks the uniform white-card rhythm.
/// Used for Family Members so that section reads differently.
class TintCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const TintCard({super.key, required this.child, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) {
    return Ticketed(
      cut: 18,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.parchmentDeep,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.clayLine),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

class HandDivider extends StatelessWidget {
  final Color color;
  const HandDivider({super.key, this.color = AppColors.clayLine});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 10),
      painter: _WavyPainter(color),
    );
  }
}

class _WavyPainter extends CustomPainter {
  final Color color;
  _WavyPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    const waves = 24;
    for (var i = 0; i <= waves; i++) {
      final x = size.width * i / waves;
      final y = 5 + (i.isEven ? -2.4 : 2.4);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FamiliaInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final TextInputType keyboard;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? formatters;
  final bool obscure;
  const FamiliaInput({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLength = 100,
    this.keyboard = TextInputType.text,
    this.onChanged,
    this.formatters,
    this.obscure = false,
  });

  @override
  State<FamiliaInput> createState() => _FamiliaInputState();
}

class _FamiliaInputState extends State<FamiliaInput> {
  final _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _focused
            ? [BoxShadow(color: AppColors.clay.withValues(alpha: 0.35), blurRadius: 14, spreadRadius: 1)]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _node,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboard,
        inputFormatters: widget.formatters,
        obscureText: widget.obscure,
        onChanged: widget.onChanged,
        cursorColor: AppColors.rust,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.workSans(color: AppColors.muted2, fontSize: 14.5),
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.clay, width: 2),
          ),
        ),
        style: GoogleFonts.workSans(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppColors.ink),
      ),
    );
  }
}

class FamiliaArea extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLength;
  const FamiliaArea({super.key, required this.controller, required this.hint, this.maxLength});

  @override
  State<FamiliaArea> createState() => _FamiliaAreaState();
}

class _FamiliaAreaState extends State<FamiliaArea> {
  final _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _focused
            ? [BoxShadow(color: AppColors.clay.withValues(alpha: 0.35), blurRadius: 14, spreadRadius: 1)]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _node,
        maxLines: 3,
        minLines: 2,
        maxLength: widget.maxLength,
        cursorColor: AppColors.rust,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.workSans(color: AppColors.muted2, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          counterStyle: GoogleFonts.workSans(fontSize: 11, color: AppColors.muted2, fontWeight: FontWeight.w600),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.clay, width: 2),
          ),
        ),
        style: GoogleFonts.workSans(fontSize: 14, color: AppColors.ink),
      ),
    );
  }
}

class HeartButton extends StatelessWidget {
  final bool fav;
  final VoidCallback tap;
  const HeartButton({super.key, required this.fav, required this.tap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10)],
        ),
        child: Icon(
          fav ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: fav ? AppColors.rust : AppColors.ink,
        ),
      ),
    );
  }
}

class FamilyRatingInput extends StatelessWidget {
  final List<(String, String)> entries;
  final Map<String, int> ratings;
  final Map<String, String> comments;
  final bool individual;
  final int step;
  final TextEditingController overallComment;
  final ValueChanged<bool> onToggleIndividual;
  final void Function(String id, int n) onRate;
  final void Function(String id, String text) onComment;
  final ValueChanged<String> onOverallComment;
  final ValueChanged<int> onStep;

  const FamilyRatingInput({
    super.key,
    required this.entries,
    required this.ratings,
    required this.comments,
    required this.individual,
    required this.step,
    required this.overallComment,
    required this.onToggleIndividual,
    required this.onRate,
    required this.onComment,
    required this.onOverallComment,
    required this.onStep,
  });

  InputDecoration _commentDec() => InputDecoration(
        hintStyle: GoogleFonts.workSans(color: AppColors.muted2, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        counterStyle: GoogleFonts.workSans(fontSize: 11, color: AppColors.muted2, fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.clay, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onToggleIndividual(!individual),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: individual ? AppColors.rust : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: individual ? AppColors.rust : AppColors.line, width: 1.5),
                ),
                child: individual
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Each person rates separately',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.workSans(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!individual) ...[
          StarRow(value: ratings['__family__'] ?? 0, onPick: (n) => onRate('__family__', n)),
          const SizedBox(height: 8),
          TextField(
            controller: overallComment,
            onChanged: onOverallComment,
            maxLines: 3,
            minLines: 2,
            maxLength: 180,
            cursorColor: AppColors.rust,
            decoration: _commentDec().copyWith(hintText: 'What did the family think?'),
            style: GoogleFonts.workSans(fontSize: 14, color: AppColors.ink),
          ),
        ] else if (entries.isEmpty) ...[
          Text('Add who went above to rate individually.',
              style: GoogleFonts.workSans(
                  fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
        ] else ...[
          Builder(builder: (context) {
            final idx = step.clamp(0, entries.length - 1);
            final (id, name) = entries[idx];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Member ${idx + 1} of ${entries.length}',
                    style: GoogleFonts.workSans(
                        fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.muted)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.rust),
                      alignment: Alignment.center,
                      child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: GoogleFonts.workSans(
                              fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w800))),
                    StarRow(value: ratings[id] ?? 0, onPick: (n) => onRate(id, n)),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: ValueKey('c_$id'),
                  initialValue: comments[id] ?? '',
                  onChanged: (v) => onComment(id, v),
                  maxLines: 2,
                  minLines: 2,
                  maxLength: 180,
                  cursorColor: AppColors.rust,
                  decoration: _commentDec().copyWith(hintText: 'What did $name think? (optional)'),
                  style: GoogleFonts.workSans(fontSize: 14, color: AppColors.ink),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (idx > 0) Expanded(child: GhostButton(label: 'Back', onTap: () => onStep(idx - 1))),
                    if (idx > 0) const SizedBox(width: 10),
                    if (idx < entries.length - 1)
                      Expanded(
                        child: Opacity(
                          opacity: (ratings[id] ?? 0) > 0 ? 1 : 0.5,
                          child: PrimaryButton(
                            label: 'Next',
                            onTap: (ratings[id] ?? 0) > 0 ? () => onStep(idx + 1) : () {},
                          ),
                        ),
                      ),
                    if (idx == entries.length - 1)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: Text('Last member — use submit below',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.workSans(
                                  fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),
        ],
      ],
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
    final bg = mintStyle ? AppColors.clay : AppColors.rust;
    return Ticketed(
      cut: 12,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: bg,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 17, color: Colors.white), const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                          fontWeight: FontWeight.w700, fontSize: 14.5, color: Colors.white, height: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          foregroundColor: AppColors.rust,
          backgroundColor: AppColors.creamCard,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.rust, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(4),
            ),
          ),
          textStyle: GoogleFonts.workSans(fontWeight: FontWeight.w700, fontSize: 13.5),
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
  const SelectChip({super.key, required this.label, required this.on, required this.tap, this.onBg = AppColors.rust});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: on ? onBg : AppColors.creamCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: on ? onBg : AppColors.line, width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: on ? Colors.white : AppColors.ink,
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
    if (dark) {
      // Standout attribute — one solid clay tag per card.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.workSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      );
    }
    // Quiet outlined chips for everything else.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.clayLine),
      ),
      child: Text(
        label,
        style: GoogleFonts.workSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.muted),
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
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => onPick(n),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: on ? AppColors.rust : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: on ? AppColors.rust : AppColors.line, width: 1.5),
              ),
              child: Icon(Icons.star, size: 15, color: on ? Colors.white : AppColors.muted2),
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
    final color = on ? AppColors.clay : Colors.white.withValues(alpha: 0.62);
    return Expanded(
      child: GestureDetector(
        onTap: () => onNav(key),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 22,
                height: 3,
                decoration: BoxDecoration(
                  color: on ? AppColors.clay : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBrown,
        border: Border(top: BorderSide(color: Color(0x22FFFFFF))),
      ),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 8 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          item(context, 'home', Icons.explore_outlined, 'Discover'),
          item(context, 'ai', Icons.auto_awesome_outlined, 'AI'),
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
          color: AppColors.parchment,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: labelFraunces(size: 20))),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.creamCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(Icons.close, size: 16, color: AppColors.rust),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: HandDivider(),
            ),
            Expanded(child: SingleChildScrollView(controller: ctrl, padding: const EdgeInsets.all(20), child: body)),
            if (foot != null)
              Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(ctx).padding.bottom),
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.line)), color: AppColors.parchment),
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
              p == null ? child : Container(width: width, height: height, color: AppColors.parchmentDeep),
          errorBuilder: (c, e, s) {
            if (u == fallback) {
              return Container(width: width, height: height, color: AppColors.parchmentDeep);
            }
            return img(fallback);
          },
        );
    final child = img(url);
    if (radius != null) return ClipRRect(borderRadius: radius!, child: child);
    return child;
  }
}
