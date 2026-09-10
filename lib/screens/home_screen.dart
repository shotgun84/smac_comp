import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data.dart';
import '../logic.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/familia_widgets.dart';

class HomeScreen extends StatelessWidget {
  final String greeting;
  final String locationText;
  final TextEditingController searchCtrl;
  final String quick;
  final List<Restaurant> items;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onQuick;
  final VoidCallback onFilters;
  final ValueChanged<String> onOpen;
  final VoidCallback onClearFilters;
  final Set<String> favorites;
  final ValueChanged<String> onFav;
  final int filterCount;
  final String syncedText;
  final Future<void> Function() onRefresh;
  const HomeScreen({
    super.key,
    required this.greeting,
    required this.locationText,
    required this.searchCtrl,
    required this.quick,
    required this.items,
    required this.onSearch,
    required this.onQuick,
    required this.onFilters,
    required this.onOpen,
    required this.onClearFilters,
    required this.favorites,
    required this.onFav,
    required this.filterCount,
    required this.syncedText,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.sageDark,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.sage,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: displayCaveat(size: 30, color: Colors.white)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFFE07B39)),
                    const SizedBox(width: 4),
                    Text(locationText,
                        style: GoogleFonts.inter(
                            fontSize: 11.5, color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 16, color: Color(0xFFACACB8)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: searchCtrl,
                                onChanged: onSearch,
                                decoration: InputDecoration(
                                  hintText: 'Search restaurants...',
                                  hintStyle: GoogleFonts.inter(color: AppColors.muted2, fontSize: 13.5),
                                  border: InputBorder.none,
                                ),
                                style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onFilters,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.sageDark,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: const Icon(Icons.tune, size: 18, color: Colors.white),
                          ),
                          if (filterCount > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE07B39),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text('$filterCount',
                                    style: GoogleFonts.inter(
                                        fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              itemCount: kQuickFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final v = kQuickFilters[i];
                final on = quick == v;
                final label = v == 'all' ? 'All' : v;
                return GestureDetector(
                  onTap: () => onQuick(v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: on ? AppColors.sageDark : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: on ? AppColors.sageDark : const Color(0xFFD8E4D5), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(label,
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.sageDark)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            child: Row(
              children: [
                Text('${items.length} spot${items.length == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.muted)),
                const Spacer(),
                Text(syncedText,
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted2)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
            child: items.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.inputBorder, style: BorderStyle.solid, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text('No restaurants match',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text('Try clearing filters or searching differently. The AI can still suggest from the full database.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
                        const SizedBox(height: 12),
                        GhostButton(label: 'Clear filters', onTap: onClearFilters),
                      ],
                    ),
                  )
                : Column(
                    children: items.map((r) {
                      final showTags = r.tags.take(3).toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () => onOpen(r.id),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                      child: NetImage(
                                        url: r.image,
                                        fallback: 'https://picsum.photos/seed/${r.id}/800/600',
                                        width: double.infinity,
                                        height: 156,
                                      ),
                                    ),
                                    Container(
                                      height: 156,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(top: Radius.circular(14)),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [Colors.black.withValues(alpha: 0.38), Colors.transparent],
                                          stops: const [0.0, 0.55],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: HeartButton(
                                        fav: favorites.contains(r.id),
                                        tap: () => onFav(r.id),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.ink.withValues(alpha: 0.88),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.schedule, size: 12, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(r.wait,
                                                style: GoogleFonts.inter(
                                                    fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(cap(r.name),
                                                style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.3,
                                                    height: 1.1)),
                                          ),
                                          const SizedBox(width: 10),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(starsDouble(r.rating),
                                                  style: const TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.sageDark,
                                                      letterSpacing: 2)),
                                              const SizedBox(width: 4),
                                              Text(r.rating.toStringAsFixed(1),
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.sageDark)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Text(cap(r.cuisine),
                                              style: GoogleFonts.inter(
                                                  fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                          Container(width: 3, height: 3, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.inputBorder)),
                                          Text('${r.price} / person',
                                              style: GoogleFonts.inter(
                                                  fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          ...showTags.asMap().entries.map((e) => MiniTag(e.value, dark: e.key == 0)),
                                          if (r.tags.length > 3) MiniTag('+${r.tags.length - 3}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
        ),
      ),
    );
  }
}
