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
      color: AppColors.rust,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageBanner(
            title: greeting,
            subtitle: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.claySoft),
                const SizedBox(width: 4),
                Text(locationText,
                    style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600)),
              ],
            ),
            bottom: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.creamCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 17, color: AppColors.muted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchCtrl,
                            onChanged: onSearch,
                            cursorColor: AppColors.rust,
                            decoration: InputDecoration(
                              hintText: 'Search restaurants...',
                              hintStyle: GoogleFonts.workSans(color: AppColors.muted2, fontSize: 13.5),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.workSans(fontSize: 13.5, fontWeight: FontWeight.w500),
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
                      Ticketed(
                        cut: 10,
                        child: Container(
                          width: 48,
                          height: 46,
                          color: AppColors.navBrown,
                          child: const Icon(Icons.tune, size: 19, color: Colors.white),
                        ),
                      ),
                      if (filterCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.clay,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text('$filterCount',
                                style: GoogleFonts.workSans(
                                    fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
              itemCount: kQuickFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final v = kQuickFilters[i];
                final on = quick == v;
                final label = v == 'all' ? 'All' : v;
                return GestureDetector(
                  onTap: () => onQuick(v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: on ? AppColors.rust : AppColors.creamCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: on ? AppColors.rust : AppColors.line, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(label,
                        style: GoogleFonts.workSans(
                            fontSize: 12.5, fontWeight: FontWeight.w700, color: on ? Colors.white : AppColors.ink)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${items.length} spot${items.length == 1 ? '' : 's'}',
                    style: labelFraunces(size: 19)),
                const Spacer(),
                Text(syncedText,
                    style: GoogleFonts.workSans(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 10, 22, 0),
            child: HandDivider(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 100),
            child: items.isEmpty
                ? Ticketed(
                    cut: 16,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.creamCard,
                        border: Border.all(color: AppColors.line, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text('No restaurants match', style: labelFraunces(size: 18)),
                          const SizedBox(height: 6),
                          Text('Try clearing filters or searching differently. The AI can still suggest from the full database.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.workSans(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
                          const SizedBox(height: 14),
                          GhostButton(label: 'Clear filters', onTap: onClearFilters),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: items.map((r) {
                      final showTags = r.tags.take(4).toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => onOpen(r.id),
                          behavior: HitTestBehavior.opaque,
                          child: Ticketed(
                            cut: 18,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.creamCard,
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      NetImage(
                                        url: r.image,
                                        fallback: 'https://picsum.photos/seed/${r.id}/800/600',
                                        width: double.infinity,
                                        height: 168,
                                      ),
                                      Container(
                                        height: 168,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [Colors.black.withValues(alpha: 0.42), Colors.transparent],
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
                                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: AppColors.navBrown.withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.schedule, size: 12, color: Colors.white),
                                              const SizedBox(width: 5),
                                              Text(r.wait,
                                                  style: GoogleFonts.workSans(
                                                      fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(cap(r.name),
                                                  style: GoogleFonts.fraunces(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: -0.3,
                                                      height: 1.1,
                                                      color: AppColors.ink)),
                                            ),
                                            const SizedBox(width: 10),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star,
                                                    size: 14, color: AppColors.rust),
                                                const SizedBox(width: 4),
                                                Text(r.rating.toStringAsFixed(1),
                                                    style: GoogleFonts.workSans(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w800,
                                                        color: AppColors.rust)),
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
                                                style: GoogleFonts.workSans(
                                                    fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                            Container(width: 3, height: 3, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.muted2)),
                                            Text('${r.price} / person',
                                                style: GoogleFonts.workSans(
                                                    fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.muted)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 7,
                                          runSpacing: 7,
                                          children: [
                                            ...showTags.asMap().entries.map((e) => MiniTag(e.value, dark: e.key == 0)),
                                            if (r.tags.length > 4) MiniTag('+${r.tags.length - 4}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
