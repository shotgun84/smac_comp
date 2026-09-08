import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/familia_widgets.dart';

class DetailScreen extends StatelessWidget {
  final Restaurant r;
  final List<FamilyReview> reviews;
  final int memberCount;
  final bool inlineOpen;
  final Map<String, int> inlineRatings;
  final TextEditingController inlineComment;
  final ValueChanged<String> onBack;
  final VoidCallback onToggleInline;
  final ValueChanged<String> onStar;
  final VoidCallback onSubmitInline;
  const DetailScreen({
    super.key,
    required this.r,
    required this.reviews,
    required this.memberCount,
    required this.inlineOpen,
    required this.inlineRatings,
    required this.inlineComment,
    required this.onBack,
    required this.onToggleInline,
    required this.onStar,
    required this.onSubmitInline,
  });

  @override
  Widget build(BuildContext context) {
    final revs = reviews.where((x) => x.restaurantId == r.id).toList();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 232,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(
                    url: r.image,
                    fallback: 'https://picsum.photos/seed/${r.id}/800/600',
                    width: double.infinity,
                    height: 232),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.52),
                        Colors.black.withValues(alpha: 0.08),
                        Colors.transparent
                      ],
                      stops: const [0.0, 0.45, 0.7],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => onBack(''),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.inputBorder)),
                      child: const Icon(Icons.arrow_back, size: 18, color: AppColors.sageDark),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: displayCaveat(size: 32, color: Colors.white)),
                      const SizedBox(height: 5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Text(starsDouble(r.rating),
                              style: const TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.w700)),
                          Text('${r.rating.toStringAsFixed(1)} / 5',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('• ${r.cuisine}',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.85))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: r.tags
                      .map((t) => MiniTag(t,
                          dark: !['Family friendly', 'Halal', 'Vegetarian options'].contains(t)))
                      .toList(),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFECE9E6)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(r.desc,
                      style: GoogleFonts.inter(fontSize: 13.5, height: 1.6, color: const Color(0xFF3A3A45))),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.55,
                  children: [
                    _info('Price / person', r.price, 'Avg. spend'),
                    _info('Opening hours', r.hours, 'Daily'),
                    _info('Average wait', r.wait, 'Family avg.'),
                    _info('Seating', r.seating.join(' + '),
                        r.seating.contains('Outdoor') ? 'Garden terrace' : 'Indoor only'),
                    _info('Languages', r.languages.join(', '), ''),
                    _info('Accessibility', r.accessibility.join(', '), ''),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onToggleInline,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.sageDark, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Review with your family',
                                  style: GoogleFonts.inter(
                                      fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text(
                                  memberCount > 0
                                      ? '$memberCount members • each rates separately'
                                      : 'Add family members • one collective review',
                                  style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color: Colors.white.withValues(alpha: 0.85))),
                            ],
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.arrow_forward, size: 18, color: AppColors.chipText),
                        ),
                      ],
                    ),
                  ),
                ),
                if (inlineOpen) ...[
                  const SizedBox(height: 12),
                  _InlineReview(
                    ratings: inlineRatings,
                    comment: inlineComment,
                    onStar: onStar,
                    onSubmit: onSubmitInline,
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.group_outlined, size: 16, color: AppColors.sageDark),
                    const SizedBox(width: 8),
                    Text('Family reviews',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration:
                          BoxDecoration(color: AppColors.sageDark, borderRadius: BorderRadius.circular(8)),
                      child: Text('${revs.length}',
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    const Spacer(),
                    Text('Newest first',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF8B8B97), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                if (revs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.inputBorder, width: 1.5),
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        Text('No family reviews yet',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('Be the first family to review ${r.name}. Tap above to create a collective review.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
                      ],
                    ),
                  )
                else
                  ...revs.map((fr) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.line),
                              borderRadius: BorderRadius.circular(14)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(fr.familyName,
                                          style: GoogleFonts.inter(
                                              fontSize: 14, fontWeight: FontWeight.w800))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: AppColors.sageDark,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star, size: 12, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text('${fr.overall.toStringAsFixed(1)} / 5',
                                            style: GoogleFonts.inter(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  '${fr.createdAt} • ${fr.members.length} opinions • family avg.'.toUpperCase(),
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFFACACB8),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6)),
                              const SizedBox(height: 8),
                              ...fr.members.map((m) => Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text(m.name,
                                                    style: GoogleFonts.inter(
                                                        fontSize: 13, fontWeight: FontWeight.w700))),
                                            Text(stars(m.rating),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.sageDark,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 2)),
                                          ],
                                        ),
                                        if (m.comment.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text('“${m.comment}”',
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  height: 1.45,
                                                  fontStyle: FontStyle.italic)),
                                        ],
                                        if (m.tags.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: m.tags
                                                .map((t) => Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 5),
                                                      decoration: BoxDecoration(
                                                          color: AppColors.mint,
                                                          border: Border.all(color: AppColors.mintBorder),
                                                          borderRadius: BorderRadius.circular(8)),
                                                      child: Text(t,
                                                          style: GoogleFonts.inter(
                                                              fontSize: 11, fontWeight: FontWeight.w600)),
                                                    ))
                                                .toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String small, String b, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(small.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: const Color(0xFF8B8B97))),
          const SizedBox(height: 5),
          Text(b,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, height: 1.3)),
          if (sub.isNotEmpty)
            Text(sub,
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8B8B97), height: 1.3)),
        ],
      ),
    );
  }
}

class _InlineReview extends StatelessWidget {
  final Map<String, int> ratings;
  final TextEditingController comment;
  final ValueChanged<String> onStar;
  final VoidCallback onSubmit;
  const _InlineReview({required this.ratings, required this.comment, required this.onStar, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Your ratings'),
          const SizedBox(height: 12),
          ...ratings.keys.map((id) {
            final parts = id.split('|');
            final name = parts.length > 1 ? parts.sublist(1).join('|') : id;
            final val = ratings[id] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF4),
                    border: Border.all(color: const Color(0xFFE3EDE1)),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sageDark),
                      alignment: Alignment.center,
                      child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700))),
                    StarRow(value: val, onPick: (n) => onStar('$id:$n')),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          const SectionLabel('Comment (shared, optional)'),
          const SizedBox(height: 8),
          FamiliaArea(controller: comment, hint: 'What did the family think?'),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Submit review', onTap: onSubmit, mintStyle: true),
        ],
      ),
    );
  }
}
