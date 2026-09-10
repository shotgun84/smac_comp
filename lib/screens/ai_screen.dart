import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/familia_widgets.dart';

class AiScreen extends StatelessWidget {
  final List<FamilyMember> members;
  final Set<String> selected;
  final TextEditingController queryCtrl;
  final bool loading;
  final List<Scored> results;
  final ValueChanged<String> onToggleEater;
  final VoidCallback onRun;
  final ValueChanged<String> onOpen;
  const AiScreen({
    super.key,
    required this.members,
    required this.selected,
    required this.queryCtrl,
    required this.loading,
    required this.results,
    required this.onToggleEater,
    required this.onRun,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sageDark),
                      child: const Icon(Icons.smart_toy_outlined, size: 15, color: Colors.white),
                    ),
                    const SizedBox(width: 9),
                    Text('Family AI', style: displayCaveat(size: 30, color: AppColors.ink)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Select who\'s eating. Allergies first, preferences second.',
                    style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF5A6E65), height: 1.5)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0EDE9)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel("Who's eating with you?"),
                const SizedBox(height: 8),
                if (members.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE0DDD8), width: 1.5),
                        borderRadius: BorderRadius.circular(14)),
                    child: Text.rich(
                      TextSpan(
                        style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF8B8B97), fontWeight: FontWeight.w600),
                        children: const [
                          TextSpan(text: 'No family members — add them in '),
                          TextSpan(text: 'Family', style: TextStyle(color: Color(0xFF111116))),
                          TextSpan(text: ' or we’ll recommend for a general family.'),
                        ],
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: members.asMap().entries.map((e) {
                      final idx = e.key;
                      final m = e.value;
                      final on = selected.contains(m.id);
                      return GestureDetector(
                        onTap: () => onToggleEater(m.id),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(9, 8, 12, 8),
                          decoration: BoxDecoration(
                            color: on ? AppColors.sageDark : AppColors.mint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: on ? AppColors.sageDark : AppColors.inputBorder, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: avatarColor(idx)),
                                alignment: Alignment.center,
                                child: Text(m.name.isEmpty ? '?' : m.name[0].toUpperCase(),
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w800, fontSize: 11.5, color: Colors.white)),
                              ),
                              const SizedBox(width: 9),
                              Text(m.name,
                                  style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: on ? Colors.white : AppColors.chipText)),
                              if (m.allergies.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text(m.allergies.first,
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: (on ? Colors.white : AppColors.chipText).withValues(alpha: 0.7))),
                              ],
                              if (on) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check, size: 14, color: Colors.white),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('What are you looking for?'),
                      TextField(
                        controller: queryCtrl,
                        maxLines: 3,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: "Find us somewhere close that isn't too expensive and has outdoor seating...",
                          hintStyle: GoogleFonts.inter(color: AppColors.muted2, fontSize: 13),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.inter(fontSize: 13.5, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: loading ? 0.6 : 1,
                        child: PrimaryButton(
                            label: loading ? 'Finding your match…' : 'Find best match',
                            onTap: onRun,
                            icon: Icons.auto_awesome_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (loading)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFECE9E6)),
                        borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.sageDark),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Finding your family match…',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13)),
                              Text('Checking requirements & preferences',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: const Color(0xFF8B8B97), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else if (results.isNotEmpty)
                  _Results(results: results, onOpen: onOpen)
                else
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.inputBorder, width: 1.5),
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        Text('Ask for a family match',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('Pick who’s eating, describe the vibe, and tap Find best match.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final List<Scored> results;
  final ValueChanged<String> onOpen;
  const _Results({required this.results, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final best = results.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (best.hardFail)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.warnBg,
                border: Border.all(color: AppColors.warnBorder),
                borderRadius: BorderRadius.circular(18)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_outlined, size: 14, color: AppColors.danger),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hard requirement warning',
                          style: GoogleFonts.inter(
                              fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.danger)),
                      Text(
                          'Top result violates a hard requirement. Showing closest alternatives — consider adjusting who\'s eating or try different keywords.',
                          style: GoogleFonts.inter(fontSize: 12.5, height: 1.5, color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (best.hardFail) const SizedBox(height: 12),
        GestureDetector(
          onTap: () => onOpen(best.r.id),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: NetImage(
                          url: best.r.image,
                          fallback: 'https://picsum.photos/seed/${best.r.id}/200/200',
                          width: 72,
                          height: 72),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppColors.mint,
                                border: Border.all(color: AppColors.mintBorder),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_outlined, size: 12, color: AppColors.chipText),
                                const SizedBox(width: 4),
                                Text('${best.match}% FAMILY MATCH',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: AppColors.chipText)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(cap(best.r.name),
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, height: 1.1)),
                          const SizedBox(height: 4),
                          Text(
                              '★ ${best.r.rating.toStringAsFixed(1)} • ${best.r.cuisine} • ${best.r.price} • ${best.r.wait}',
                              style: GoogleFonts.inter(
                                  fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: best.r.tags
                      .take(3)
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                                color: AppColors.mint,
                                border: Border.all(color: AppColors.mintBorder),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(t,
                                style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.chipText)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF2F7F0),
                      border: Border.all(color: const Color(0xFFD8E4D5)),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI REASONING',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                              color: AppColors.sageDark)),
                      const SizedBox(height: 8),
                      ...(best.reasons.isEmpty
                              ? ['✓ Good overall match for your query', '✓ Highly rated by families', '✓ ${best.r.distance} away']
                              : best.reasons)
                          .map((x) => Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 14, color: AppColors.sageDark),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(x.replaceAll('✓ ', ''),
                                            style: GoogleFonts.inter(fontSize: 12.5, height: 1.4))),
                                  ],
                                ),
                              )),
                      if (best.blocks.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.cancel_outlined, size: 14, color: AppColors.reqBrown),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(best.blocks.first,
                                    style: GoogleFonts.inter(
                                        fontSize: 12.5, height: 1.4, color: AppColors.danger))),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(label: 'View restaurant', onTap: () => onOpen(best.r.id), mintStyle: true, icon: Icons.arrow_forward),
                const SizedBox(height: 8),
                Center(
                    child: Text('Ranked for your family',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('ALSO GOOD MATCHES',
            style:
                GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: AppColors.muted)),
        const SizedBox(height: 8),
        ...results.skip(1).map((sc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onOpen(sc.r.id),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NetImage(
                            url: sc.r.image,
                            fallback: 'https://picsum.photos/seed/${sc.r.id}/200/200',
                            width: 64,
                            height: 64),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(cap(sc.r.name),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800))),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: sc.hardFail ? const Color(0xFFFDEEDC) : AppColors.mint,
                                      border: Border.all(
                                          color: sc.hardFail
                                              ? const Color(0xFFE8C48A)
                                              : AppColors.mintBorder),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text('${sc.match}%',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: sc.hardFail ? AppColors.danger : AppColors.chipText)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${sc.r.cuisine} • ${sc.r.price} • ★ ${sc.r.rating.toStringAsFixed(1)}',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(
                                (sc.reasons.isEmpty ? 'Good match' : sc.reasons.first).replaceAll('✓ ', '✓ '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.ink)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.muted2),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

