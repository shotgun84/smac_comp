import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend.dart';
import 'config.dart';
import 'data.dart';
import 'logic.dart';
import 'models.dart';
import 'screens/ai_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/family_screen.dart';
import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/review_screen.dart';
import 'theme.dart';
import 'widgets/familia_widgets.dart';

class FamiliaRoot extends StatefulWidget {
  const FamiliaRoot({super.key});

  @override
  State<FamiliaRoot> createState() => _FamiliaRootState();
}

class _FamiliaRootState extends State<FamiliaRoot> {
  String screen = 'landing';
  String nav = 'home';

  String familyName = '';
  List<FamilyMember> members = [];
  Set<String> selectedEaters = {};

  List<Restaurant> restaurants = [];
  List<FamilyReview> reviews = [];
  bool loading = true;
  String? loadError;

  String search = '';
  String quick = 'all';
  Filters filters = Filters();
  String currentId = '';

  final familyNameCtrl = TextEditingController();
  final searchCtrl = TextEditingController();
  final aiCtrl = TextEditingController();

  NewRestaurantDraft draft = NewRestaurantDraft();
  final nrName = TextEditingController();
  final nrHours = TextEditingController();
  final nrBill = TextEditingController();
  final nrComment = TextEditingController();

  String? editingMemberId;
  String memberDraftName = '';
  List<String> memberDietary = [];
  List<String> memberAllergies = [];
  List<String> memberPrefs = [];
  final memberNameCtrl = TextEditingController();

  bool aiLoading = false;
  List<Scored> aiResults = [];

  bool inlineOpen = false;
  Map<String, int> inlineRatings = {};
  final inlineComment = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      final qp = Uri.base.queryParameters['screen'];
      if (qp != null && const ['landing', 'setup', 'home', 'detail', 'review', 'ai'].contains(qp)) {
        screen = qp;
        if (qp == 'home' || qp == 'detail') nav = 'home';
        if (qp == 'ai') nav = 'ai';
        if (qp == 'review') nav = 'reviews';
        if (qp == 'setup') nav = 'family';
      }
    } catch (_) {}
    unawaited(loadData());
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final rs = await fetchRestaurants();
      List<FamilyReview> revs = [];
      try {
        revs = await fetchReviews();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        restaurants = rs;
        reviews = revs;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadError = 'Couldn\'t reach the restaurant database. Check your connection and retry.';
      });
    }
  }

  @override
  void dispose() {
    familyNameCtrl.dispose();
    searchCtrl.dispose();
    aiCtrl.dispose();
    nrName.dispose();
    nrHours.dispose();
    nrBill.dispose();
    nrComment.dispose();
    memberNameCtrl.dispose();
    inlineComment.dispose();
    super.dispose();
  }

  void go(String s, [String? n]) {
    setState(() {
      screen = s;
      if (n != null) nav = n;
      if (s == 'home' && n == null) nav = 'home';
      if (s == 'ai') nav = 'ai';
      if (s == 'review') nav = 'reviews';
      if (s == 'setup') nav = 'family';
    });
  }

  void onNav(String key) {
    if (key == 'home') {
      go('home', 'home');
    } else if (key == 'ai') {
      go('ai', 'ai');
    } else if (key == 'reviews') {
      openNewReview();
    } else if (key == 'family') {
      go('setup', 'family');
    }
  }

  void openRestaurant(String id) {
    setState(() {
      currentId = id;
      inlineOpen = false;
      inlineRatings = {};
      inlineComment.clear();
      screen = 'detail';
    });
  }

  Restaurant? get current {
    if (restaurants.isEmpty) return null;
    return restaurants.where((r) => r.id == currentId).firstOrNull ?? restaurants.first;
  }

  List<Restaurant> get filtered =>
      getFiltered(restaurants, search: search, quick: quick, filters: filters);

  String get locationText =>
      filters.emirate == 'any' ? 'UAE • All Emirates' : 'UAE • ${filters.emirate}';

  void openNewReview() {
    setState(() {
      if (draft.who.isEmpty && members.isNotEmpty && nrName.text.isEmpty && nrComment.text.isEmpty) {
        draft.who = members.map((m) => m.id).toList();
      }
      screen = 'review';
      nav = 'reviews';
    });
  }

  void resetNrForm() {
    setState(() {
      draft = NewRestaurantDraft();
      draft.who = members.map((m) => m.id).toList();
      for (final c in [nrName, nrHours, nrBill, nrComment]) {
        c.clear();
      }
    });
  }

  void submitNewRestaurant() {
    final name = nrName.text.trim();
    if (name.isEmpty) {
      snack('Add the restaurant name first');
      return;
    }
    if (members.isNotEmpty && draft.who.isEmpty) {
      snack('Pick who went first');
      return;
    }
    final ids = (members.isEmpty ? ['__guest__'] : draft.who)
        .where((id) => (draft.ratings[id] ?? 0) > 0)
        .toList();
    if (ids.isEmpty) {
      snack('Add at least one family rating');
      return;
    }
    final avg = ids.map((id) => draft.ratings[id]!).reduce((a, b) => a + b) / ids.length;
    final bill = double.tryParse(draft.bill) ?? 0;
    final per = (bill > 0 && draft.party > 0) ? (bill / draft.party).round() : null;
    final rId = 'u${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    final comment = nrComment.text.trim();
    final famName = familyName.isEmpty ? 'Your family' : familyName;
    final tags = ['New', ...draft.tags].take(8).toList();
    final dietary = <String>[];
    if (tags.contains('Vegetarian options')) dietary.add('Vegetarian');
    if (tags.contains('Vegan options')) dietary.add('Vegan');
    if (tags.contains('Gluten-free')) dietary.add('Gluten-free');
    if (tags.contains('Halal')) dietary.add('Halal');
    final city = '${draft.city}, UAE';
    final resto = Restaurant(
      id: rId,
      name: name,
      cuisine: draft.cuisine.isEmpty ? 'Other' : draft.cuisine,
      rating: (avg * 10).round() / 10,
      price: per != null ? 'AED ~$per' : 'AED —',
      priceNum: (per ?? 999).toDouble(),
      distance: '—',
      distanceNum: 0,
      wait: draft.wait.isEmpty ? '~15 min' : draft.wait,
      waitNum: kNrWaitNum[draft.wait] ?? 15,
      tags: tags,
      dietary: dietary,
      seating: draft.seating.isEmpty ? ['Indoor'] : List.of(draft.seating),
      languages: List.of(draft.langs),
      accessibility: List.of(draft.access),
      image: 'https://picsum.photos/seed/$rId/800/600',
      desc: comment.isEmpty ? 'Added by $famName.' : comment,
      hours: nrHours.text.trim().isEmpty ? '—' : nrHours.text.trim(),
      city: city,
      address: city,
      lat: '—',
    );
    String memberName(String id) {
      if (id == '__guest__') return 'Guest';
      final m = members.where((x) => x.id == id).firstOrNull;
      return m?.name ?? 'Guest';
    }

    final review = FamilyReview(
      id: 'r$rId',
      restaurantId: rId,
      familyName: famName,
      overall: (avg * 10).round() / 10,
      createdAt: 'Just now',
      members: ids
          .map((id) => MemberReview(name: memberName(id), rating: draft.ratings[id]!, comment: comment))
          .toList(),
    );
    setState(() {
      restaurants.insert(0, resto);
      reviews.insert(0, review);
      currentId = rId;
    });
    saveRestaurant(resto).then((ok) {
      if (!mounted) return;
      if (!ok) snack('Saved on this device — offline');
    });
    saveReview(review).then((_) {});
    resetNrForm();
    go('home', 'home');
    snack('$name added to Discover');
  }

  Future<void> runAi() async {
    final q = aiCtrl.text.trim();
    final eaters = selectedEaters.isNotEmpty
        ? members.where((m) => selectedEaters.contains(m.id)).toList()
        : List<FamilyMember>.of(members);
    setState(() {
      aiLoading = true;
    });
    if (kOpenAiEnabled && q.length > 1 && restaurants.isNotEmpty) {
      try {
        final gptTop = await getGptRecommendations(query: q, eaters: eaters, restaurants: restaurants);
        if (!mounted) return;
        if (gptTop.length >= 2) {
          setState(() {
            aiResults = gptTop.take(3).toList();
            aiLoading = false;
          });
          return;
        }
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('429')) {
          snack('AI busy — using local ranking');
        } else if (msg.contains('401') || msg.contains('403')) {
          snack('AI key error — using local ranking');
        }
      }
    }
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final scored = scoreLocally(q, eaters, restaurants, reviews, familyName);
    setState(() {
      aiResults = scored.take(3).toList();
      aiLoading = false;
    });
  }

  void snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)), duration: const Duration(seconds: 2)),
    );
  }

  void openMemberSheet(String? id) {
    final m = id == null ? null : members.where((x) => x.id == id).firstOrNull;
    setState(() {
      editingMemberId = id;
      memberDraftName = m?.name ?? '';
      memberDietary = List.of(m?.dietary ?? []);
      memberAllergies = List.of(m?.allergies ?? []);
      memberPrefs = List.of(m?.prefs ?? []);
      memberNameCtrl.text = memberDraftName;
    });
    showFamiliaSheet(
      context,
      m == null ? 'Add family member' : 'Edit ${m.name}',
      StatefulBuilder(
        builder: (ctx, setSheet) {
          void toggle(List<String> list, String v) {
            if (list.contains(v)) {
              list.remove(v);
            } else {
              list.add(v);
            }
            setSheet(() {});
            setState(() {});
          }

          Widget grid(List<String> options, List<String> sel, Color onBg) => Wrap(
                spacing: 6,
                runSpacing: 6,
                children: options
                    .map((v) => SelectChip(label: v, on: sel.contains(v), tap: () => toggle(sel, v), onBg: onBg))
                    .toList(),
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Member name'),
              const SizedBox(height: 6),
              FamiliaInput(
                  controller: memberNameCtrl,
                  hint: 'e.g. Mom, Dad, Owais, Sara',
                  maxLength: 24,
                  onChanged: (v) => memberDraftName = v),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.reqBrown)),
                  const SizedBox(width: 8),
                  const SectionLabel('Dietary requirements'),
                ],
              ),
              Text('hard — must have',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFACACB8))),
              const SizedBox(height: 6),
              grid(kDietary, memberDietary, AppColors.reqBrown),
              const SizedBox(height: 6),
              Text('Allergic to something? Pick it under Allergies below — we exclude it automatically.',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 12),
              const SectionLabel('Allergies'),
              Text('hard — cannot have',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFACACB8))),
              const SizedBox(height: 6),
              grid(kAllergies, memberAllergies, AppColors.ink),
              const SizedBox(height: 12),
              const SectionLabel('Dining preferences'),
              Text('soft — venue & vibe',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFACACB8))),
              const SizedBox(height: 6),
              grid(kDiningPrefs, memberPrefs, AppColors.sageDark),
              const SizedBox(height: 12),
              const SectionLabel('Personal tastes'),
              Text('soft — personal',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFACACB8))),
              const SizedBox(height: 6),
              grid(kTastePrefs, memberPrefs, AppColors.sageDark),
            ],
          );
        },
      ),
      foot: Row(
        children: [
          if (m != null)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    members.removeWhere((x) => x.id == editingMemberId);
                    selectedEaters.remove(editingMemberId);
                    editingMemberId = null;
                  });
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Color(0xFFE8C48A)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Remove'),
              ),
            ),
          if (m != null) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                final name = memberNameCtrl.text.trim().isEmpty
                    ? 'Member ${members.length + 1}'
                    : memberNameCtrl.text.trim();
                setState(() {
                  if (editingMemberId != null) {
                    final idx = members.indexWhere((x) => x.id == editingMemberId);
                    if (idx >= 0) {
                      members[idx] = FamilyMember(
                        id: members[idx].id,
                        name: name,
                        dietary: List.of(memberDietary),
                        allergies: List.of(memberAllergies),
                        prefs: List.of(memberPrefs),
                      );
                    }
                  } else {
                    if (members.length >= 10) {
                      snack('Max 10 members for demo');
                      return;
                    }
                    final newId = 'm${DateTime.now().millisecondsSinceEpoch}';
                    members.add(FamilyMember(
                      id: newId,
                      name: name,
                      dietary: List.of(memberDietary),
                      allergies: List.of(memberAllergies),
                      prefs: List.of(memberPrefs),
                    ));
                    selectedEaters.add(newId);
                  }
                  editingMemberId = null;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageDark,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Save member'),
            ),
          ),
        ],
      ),
    );
  }

  void openFilterSheet() {
    showFamiliaSheet(
      context,
      'Filters',
      StatefulBuilder(
        builder: (ctx, setSheet) {
          Widget singleRow(String kind, List<(String, String)> opts) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opts.map((o) {
                  final cur = kind == 'emirate'
                      ? filters.emirate
                      : kind == 'price'
                          ? filters.price
                          : filters.rating;
                  final on = cur == o.$1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (kind == 'emirate') filters.emirate = o.$1;
                        if (kind == 'price') filters.price = o.$1;
                        if (kind == 'rating') filters.rating = o.$1;
                      });
                      setSheet(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: on ? AppColors.sageDark : AppColors.mint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: on ? AppColors.sageDark : AppColors.inputBorder, width: 1.5),
                      ),
                      child: Text(o.$2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: on ? Colors.white : AppColors.chipText)),
                    ),
                  );
                }).toList(),
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Emirate'),
              const SizedBox(height: 8),
              singleRow('emirate', [('any', 'All Emirates'), ...kEmirates.map((e) => (e, e))]),
              const SizedBox(height: 14),
              const SectionLabel('Price / person'),
              const SizedBox(height: 8),
              singleRow('price', const [('cheap', 'Under AED 50'), ('mid', 'AED 50–100'), ('any', 'Any')]),
              const SizedBox(height: 14),
              const SectionLabel('Rating'),
              const SizedBox(height: 8),
              singleRow('rating', const [('any', 'Any'), ('4', '4.5★+'), ('4.3', '4.3★+')]),
              const SizedBox(height: 14),
              const SectionLabel('Cuisine'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: kCuisines
                    .map((c) => SelectChip(
                        label: c,
                        on: filters.cuisines.contains(c),
                        tap: () {
                          setState(() {
                            if (filters.cuisines.contains(c)) {
                              filters.cuisines.remove(c);
                            } else {
                              filters.cuisines.add(c);
                            }
                          });
                          setSheet(() {});
                        }))
                    .toList(),
              ),
              const SizedBox(height: 14),
              const SectionLabel('Dietary / seating'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: kFilterDietary
                    .map((c) => SelectChip(
                        label: c,
                        on: filters.dietary.contains(c),
                        tap: () {
                          setState(() {
                            if (filters.dietary.contains(c)) {
                              filters.dietary.remove(c);
                            } else {
                              filters.dietary.add(c);
                            }
                          });
                          setSheet(() {});
                        }))
                    .toList(),
              ),
            ],
          );
        },
      ),
      foot: Row(
        children: [
          Expanded(child: GhostButton(label: 'Clear', onTap: () {
            setState(() => filters.clear());
            Navigator.pop(context);
          })),
          const SizedBox(width: 10),
          Expanded(
              flex: 2,
              child: PrimaryButton(
                  label: 'Apply filters',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {});
                  })),
        ],
      ),
    );
  }

  void toggleInline() {
    setState(() {
      if (inlineOpen) {
        inlineOpen = false;
        return;
      }
      inlineOpen = true;
      inlineComment.clear();
      if (members.isEmpty) {
        inlineRatings = {'__guest__|Guest': 0};
      } else {
        inlineRatings = {for (final m in members) '${m.id}|${m.name}': 0};
      }
    });
  }

  void submitInline() {
    final ids = inlineRatings.keys.where((k) => (inlineRatings[k] ?? 0) > 0).toList();
    if (ids.isEmpty) {
      snack('Tap stars to rate first');
      return;
    }
    final avg = ids.map((k) => inlineRatings[k]!).reduce((a, b) => a + b) / ids.length;
    final comment = inlineComment.text.trim();
    String nameOf(String key) {
      final parts = key.split('|');
      return parts.length > 1 ? parts.sublist(1).join('|') : key;
    }

    final review = FamilyReview(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: currentId,
      familyName: familyName.isEmpty ? 'Your family' : familyName,
      overall: (avg * 10).round() / 10,
      createdAt: 'Just now',
      members: ids
          .map((k) => MemberReview(name: nameOf(k), rating: inlineRatings[k]!, comment: comment))
          .toList(),
    );
    setState(() {
      reviews.insert(0, review);
      inlineOpen = false;
      inlineRatings = {};
      inlineComment.clear();
    });
    saveReview(review).then((ok) {
      if (!mounted || ok) return;
      snack('Saved on this device — offline');
    });
    snack('Family review saved • ${avg.toStringAsFixed(1)}★');
  }

  double get nrAvg {
    final ids = draft.who.isEmpty && members.isEmpty ? ['__guest__'] : draft.who;
    final vals = ids.map((id) => draft.ratings[id] ?? 0).where((v) => v > 0).toList();
    if (vals.isEmpty) return 0;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  Widget _loadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.sageDark),
            ),
            const SizedBox(height: 14),
            Text('Loading restaurants…',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _loadErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Couldn\'t load restaurants',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(loadError ?? 'Check your connection and retry.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted, height: 1.5)),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: PrimaryButton(label: 'Retry', onTap: loadData),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (screen) {
      case 'landing':
        content = LandingScreen(
          onCreate: () => go('setup', 'family'),
          onSkip: () {
            setState(() {
              selectedEaters = members.map((m) => m.id).toSet();
            });
            go('home', 'home');
          },
        );
        break;
      case 'setup':
        content = FamilyScreen(
          familyName: familyName,
          members: members,
          nameCtrl: familyNameCtrl,
          onName: (v) => setState(() => familyName = v.trim()),
          onAdd: () => openMemberSheet(null),
          onEdit: (id) => openMemberSheet(id),
        );
        break;
      case 'home':
        if (loading) {
          content = _loadingView();
        } else if (loadError != null && restaurants.isEmpty) {
          content = _loadErrorView();
        } else {
          content = HomeScreen(
            greeting: greetingFor(familyName),
            locationText: locationText,
            searchCtrl: searchCtrl,
            quick: quick,
            items: filtered,
            onSearch: (v) => setState(() => search = v),
            onQuick: (v) => setState(() => quick = v),
            onFilters: openFilterSheet,
            onOpen: openRestaurant,
            onClearFilters: () => setState(() {
              filters.clear();
              search = '';
              quick = 'all';
              searchCtrl.clear();
            }),
          );
        }
        break;
      case 'detail':
        final r = current;
        content = r == null
            ? _loadErrorView()
            : DetailScreen(
                r: r,
                reviews: reviews,
                memberCount: members.length,
                inlineOpen: inlineOpen,
                inlineRatings: inlineRatings,
                inlineComment: inlineComment,
                onBack: (_) => go('home', 'home'),
                onToggleInline: toggleInline,
                onStar: (coded) {
                  final idx = coded.lastIndexOf(':');
                  final key = coded.substring(0, idx);
                  final n = int.parse(coded.substring(idx + 1));
                  setState(() => inlineRatings[key] = n);
                },
                onSubmitInline: submitInline,
              );
        break;
      case 'review':
        content = ReviewScreen(
          draft: draft,
          members: members,
          nameCtrl: nrName,
          hoursCtrl: nrHours,
          billCtrl: nrBill,
          commentCtrl: nrComment,
          refresh: () => setState(() {}),
          onClear: resetNrForm,
          onSubmit: submitNewRestaurant,
        );
        break;
      case 'ai':
      default:
        content = AiScreen(
          members: members,
          selected: selectedEaters,
          queryCtrl: aiCtrl,
          loading: aiLoading,
          results: aiResults,
          onToggleEater: (id) => setState(() {
            if (selectedEaters.contains(id)) {
              selectedEaters.remove(id);
            } else {
              selectedEaters.add(id);
            }
          }),
          onRun: runAi,
          onOpen: openRestaurant,
        );
        break;
    }

    final showNav = screen != 'landing';
    final showReviewFoot = screen == 'review';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 520;
          final panel = Container(
            constraints: const BoxConstraints(maxWidth: 430),
            decoration: wide
                ? BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.line),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.sageDark.withValues(alpha: 0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 20)),
                    ],
                  )
                : const BoxDecoration(color: AppColors.cream),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(child: content),
                if (showReviewFoot)
                  ReviewFooter(avg: nrAvg, onClear: resetNrForm, onSubmit: submitNewRestaurant),
                if (showNav) FamiliaBottomNav(current: nav, onNav: onNav),
              ],
            ),
          );
          if (!wide) return panel;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(height: c.maxHeight - 48, child: panel),
            ),
          );
        },
      ),
    );
  }
}
