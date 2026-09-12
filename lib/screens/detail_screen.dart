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
  final bool isFav;
  final VoidCallback onFav;
  final List<(String, String)> inlineEntries;
  final Map<String, int> inlineRatings;
  final Map<String, String> inlineComments;
  final bool inlineIndividual;
  final int inlineStep;
  final TextEditingController inlineComment;
  final ValueChanged<String> onBack;
  final VoidCallback onToggleInline;
  final void Function(String id, int n) onStar;
  final void Function(String id, String text) onInlineComment;
  final ValueChanged<String> onOverallComment;
  final ValueChanged<bool> onToggleIndividual;
  final ValueChanged<int> onStep;
  final VoidCallback onSubmitInline;
  const DetailScreen({
    super.key,
    required this.r,
    required this.reviews,
    required this.memberCount,
    required this.inlineOpen,
    required this.isFav,
    required this.onFav,
    required this.inlineEntries,
    required this.inlineRatings,
    required this.inlineComments,
    required this.inlineIndividual,
    required this.inlineStep,
    required this.inlineComment,
    required this.onBack,
    required this.onToggleInline,
    required this.onStar,
    required this.onInlineComment,
    required this.onOverallComment,
    required this.onToggleIndividual,
    required this.onStep,
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
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(
                    url: r.image,
                    fallback: 'https://picsum.photos/seed/${r.id}/800/600',
                    width: double.infinity,
                    height: 250),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.black.withValues(alpha: 0.1),
                        Colors.transparent
                      ],
                      stops: const [0.0, 0.5, 0.75],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => onBack(''),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                          child: const Icon(Icons.arrow_back, size: 18, color: AppColors.rust),
                        ),
                      ),
                      HeartButton(fav: isFav, tap: onFav),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cap(r.name), style: displayFraunces(size: 34, color: Colors.white, italic: true)),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          const Icon(Icons.star, size: 13, color: AppColors.claySoft),
                          Text('${r.rating.toStringAsFixed(1)} / 5',
                              style: GoogleFonts.workSans(
                                  fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('• ${cap(r.cuisine)}',
                              style: GoogleFonts.workSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.88))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: r.tags
                      .take(5)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) => MiniTag(e.value, dark: e.key == 0))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Ticketed(
                  cut: 14,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.creamCard,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(cap(r.desc),
                        style: GoogleFonts.workSans(fontSize: 13.5, height: 1.65, color: AppColors.ink)),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.55,
                  children: [
                    _info('Price / person', r.price, 'Avg. spend'),
                    _info('Opening hours', r.hours, r.hours == '—' ? '' : 'Daily'),
                    _info('Average wait', r.wait, 'Family avg.'),
                    _info('Seating', r.seating.join(' + '),
                        r.seating.contains('Outdoor') ? 'Garden terrace' : 'Indoor only'),
                    _info('Languages', r.languages.join(', '), ''),
                    _info('Accessibility', r.accessibility.join(', '), ''),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onToggleInline,
                  child: Ticketed(
                    cut: 14,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: AppColors.rust,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Review with your family',
                                    style: GoogleFonts.fraunces(
                                        fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text(
                                    memberCount > 0
                                        ? '$memberCount members • each rates separately'
                                        : 'Add family members • one collective review',
                                    style: GoogleFonts.workSans(
                                        fontSize: 12.5,
                                        color: Colors.white.withValues(alpha: 0.85))),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: AppColors.clay, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.arrow_forward, size: 19, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (inlineOpen) ...[
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    final iwEntries = inlineEntries;
                    return Ticketed(
                      cut: 14,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: AppColors.creamCard,
                            border: Border.all(color: AppColors.line)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel('Your ratings'),
                            const SizedBox(height: 14),
                            FamilyRatingInput(
                              entries: iwEntries,
                              ratings: inlineRatings,
                              comments: inlineComments,
                              individual: inlineIndividual,
                              step: inlineStep,
                              overallComment: inlineComment,
                              onToggleIndividual: onToggleIndividual,
                              onRate: onStar,
                              onComment: onInlineComment,
                              onOverallComment: onOverallComment,
                              onStep: onStep,
                            ),
                            const SizedBox(height: 14),
                            PrimaryButton(
                                label: 'Submit review', onTap: onSubmitInline, mintStyle: true),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 18),
                const HandDivider(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.group_outlined, size: 17, color: AppColors.rust),
                    const SizedBox(width: 8),
                    Text('Family reviews', style: labelFraunces(size: 19)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration:
                          BoxDecoration(color: AppColors.clay, borderRadius: BorderRadius.circular(8)),
                      child: Text('${revs.length}',
                          style: GoogleFonts.workSans(
                              fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (revs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: AppColors.creamCard,
                        border: Border.all(color: AppColors.line, width: 1.5),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Text('No family reviews yet', style: labelFraunces(size: 17)),
                        const SizedBox(height: 6),
                        Text('Be the first family to review ${r.name}. Tap above to create a collective review.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.workSans(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
                      ],
                    ),
                  )
                else
                  ...revs.map((fr) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Ticketed(
                          cut: 12,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                                color: AppColors.creamCard,
                                border: Border.all(color: AppColors.line)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(cap(fr.familyName),
                                            style: GoogleFonts.workSans(
                                                fontSize: 14, fontWeight: FontWeight.w800))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: AppColors.rust,
                                          borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, size: 12, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text('${fr.overall.toStringAsFixed(1)} / 5',
                                              style: GoogleFonts.workSans(
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
                                    style: GoogleFonts.workSans(
                                        fontSize: 10.5,
                                        color: AppColors.muted2,
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
                                                  child: Text(cap(m.name),
                                                      style: GoogleFonts.workSans(
                                                          fontSize: 13, fontWeight: FontWeight.w700))),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: List.generate(5, (i) => Icon(
                                                  Icons.star,
                                                  size: 12,
                                                  color: i < m.rating ? AppColors.rust : AppColors.line,
                                                )),
                                              ),
                                            ],
                                          ),
                                          if (m.comment.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text('“${m.comment}”',
                                                style: GoogleFonts.workSans(
                                                    fontSize: 13,
                                                    height: 1.5,
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
                                                            horizontal: 9, vertical: 6),
                                                        decoration: BoxDecoration(
                                                            color: Colors.transparent,
                                                            border: Border.all(color: AppColors.clayLine),
                                                            borderRadius: BorderRadius.circular(8)),
                                                        child: Text(t,
                                                            style: GoogleFonts.workSans(
                                                                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted)),
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: AppColors.creamCard, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(small,
              style: GoogleFonts.fraunces(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted)),
          const SizedBox(height: 5),
          Text(b,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.workSans(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.3)),
          if (sub.isNotEmpty)
            Text(sub,
                style: GoogleFonts.workSans(fontSize: 11, color: AppColors.muted, height: 1.3)),
        ],
      ),
    );
  }
}
