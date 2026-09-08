import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/familia_widgets.dart';

class ReviewScreen extends StatelessWidget {
  final NewRestaurantDraft draft;
  final List<FamilyMember> members;
  final TextEditingController nameCtrl;
  final TextEditingController hoursCtrl;
  final TextEditingController billCtrl;
  final TextEditingController commentCtrl;
  final VoidCallback refresh;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  const ReviewScreen({
    super.key,
    required this.draft,
    required this.members,
    required this.nameCtrl,
    required this.hoursCtrl,
    required this.billCtrl,
    required this.commentCtrl,
    required this.refresh,
    required this.onClear,
    required this.onSubmit,
  });

  void toggleList(List<String> list, String v) {
    if (list.contains(v)) {
      list.remove(v);
    } else {
      list.add(v);
    }
    refresh();
  }

  String get perPerson {
    final bill = double.tryParse(draft.bill) ?? 0;
    if (bill > 0 && draft.party > 0) {
      return 'Per person: ~AED ${(bill / draft.party).round()} • ${draft.party} people';
    }
    return 'Per person: —';
  }

  double get avg {
    final ids = draft.who.isEmpty && members.isEmpty ? ['__guest__'] : draft.who;
    final vals = ids.map((id) => draft.ratings[id] ?? 0).where((v) => v > 0).toList();
    if (vals.isEmpty) return 0;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.sage,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New restaurant review',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Been somewhere new? Add it for every family.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              children: [
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Restaurant name'),
                      const SizedBox(height: 8),
                      FamiliaInput(controller: nameCtrl, hint: 'e.g. Olive Branch', maxLength: 40,
                          onChanged: (v) => draft.name = v),
                      const SizedBox(height: 14),
                      const SectionLabel('Photo'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF6FAF4),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.add_a_photo_outlined, size: 22, color: AppColors.muted),
                            const SizedBox(height: 8),
                            Text('Photos attach on device builds',
                                style: GoogleFonts.inter(
                                    fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Cuisine'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: kCuisines
                            .map((c) => SelectChip(
                                label: c,
                                on: draft.cuisine == c,
                                tap: () {
                                  draft.cuisine = draft.cuisine == c ? '' : c;
                                  refresh();
                                }))
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel('Seating'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: kNrSeating
                            .map((c) => SelectChip(
                                label: c, on: draft.seating.contains(c), tap: () => toggleList(draft.seating, c)))
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel('Opening hours'),
                      const SizedBox(height: 8),
                      FamiliaInput(controller: hoursCtrl, hint: 'e.g. 11:00 AM – 11:00 PM',
                          maxLength: 40, onChanged: (v) => draft.hours = v),
                      const SizedBox(height: 14),
                      const SectionLabel('Emirate'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: kEmirates.contains(draft.city) ? draft.city : kEmirates.first,
                        items: kEmirates
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.ink)),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            draft.city = v;
                            refresh();
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.inputBorder, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.sageDark, width: 1.5),
                          ),
                        ),
                        dropdownColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Your visit'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Party size',
                                    style: GoogleFonts.inter(
                                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: AppColors.inputBorder, width: 1.5),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _step('−', () {
                                        draft.party = (draft.party - 1).clamp(1, 20);
                                        refresh();
                                      }),
                                      Text('${draft.party}',
                                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800)),
                                      _step('+', () {
                                        draft.party = (draft.party + 1).clamp(1, 20);
                                        refresh();
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total bill (AED)',
                                    style: GoogleFonts.inter(
                                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
                                const SizedBox(height: 8),
                                FamiliaInput(controller: billCtrl, hint: 'e.g. 180',
                                    keyboard: TextInputType.number, maxLength: 7,
                                    onChanged: (v) {
                                      draft.bill = v;
                                      refresh();
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(perPerson, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFA9A9B6))),
                      const SizedBox(height: 14),
                      const SectionLabel('Wait for food'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: kNrWait
                            .map((c) => SelectChip(
                                label: c,
                                on: draft.wait == c,
                                tap: () {
                                  draft.wait = c;
                                  refresh();
                                }))
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel('Languages staff spoke'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: kNrLangs
                            .map((c) => SelectChip(
                                label: c, on: draft.langs.contains(c), tap: () => toggleList(draft.langs, c)))
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      const SectionLabel('Accessibility'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: kNrAccess
                            .map((c) => SelectChip(
                                label: c, on: draft.access.contains(c), tap: () => toggleList(draft.access, c)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Good to know'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: kNrTags
                            .map((c) => SelectChip(
                                label: c, on: draft.tags.contains(c), tap: () => toggleList(draft.tags, c)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Who went?'),
                      const SizedBox(height: 8),
                      if (members.isEmpty)
                        Text('No family members — reviewing as Guest.',
                            style: GoogleFonts.inter(
                                fontSize: 12.5, color: const Color(0xFF8B8B97), fontWeight: FontWeight.w600))
                      else
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: members
                              .map((m) => SelectChip(
                                  label: m.name,
                                  on: draft.who.contains(m.id),
                                  tap: () {
                                    toggleList(draft.who, m.id);
                                    if (!draft.who.contains(m.id)) draft.ratings.remove(m.id);
                                  }))
                              .toList(),
                        ),
                      const SizedBox(height: 14),
                      const SectionLabel('Family ratings'),
                      const SizedBox(height: 8),
                      ..._ratingRows(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const SectionLabel('What stood out? '),
                          Text('(shared)',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: const Color(0xFFACACB8), fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FamiliaArea(controller: commentCtrl, hint: 'One short note the whole family agrees on…'),
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

  List<Widget> _ratingRows() {
    final ids = draft.who.isEmpty && members.isEmpty ? ['__guest__|Guest'] : draft.who.map((id) {
      final m = members.where((x) => x.id == id).firstOrNull;
      return '$id|${m?.name ?? 'Guest'}';
    }).toList();
    if (members.isNotEmpty && draft.who.isEmpty) {
      return [
        Text('Select who went above.',
            style:
                GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF8B8B97), fontWeight: FontWeight.w600))
      ];
    }
    return ids.map((key) {
      final name = key.split('|').length > 1 ? key.split('|').sublist(1).join('|') : key;
      final id = key.split('|').first;
      final val = draft.ratings[id] ?? 0;
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
                    style:
                        GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700))),
              StarRow(
                  value: val,
                  onPick: (n) {
                    draft.ratings[id] = n;
                    refresh();
                  }),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _step(String label, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
            color: AppColors.mint,
            border: Border.all(color: AppColors.inputBorder, width: 1.5),
            borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Text(label, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class ReviewFooter extends StatelessWidget {
  final double avg;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  const ReviewFooter({super.key, required this.avg, required this.onClear, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 12 + MediaQuery.of(context).padding.bottom),
      decoration:
          const BoxDecoration(color: AppColors.cream, border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        children: [
          Expanded(child: GhostButton(label: 'Clear', onTap: onClear)),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: PrimaryButton(
                label: 'Add restaurant • ${avg > 0 ? avg.toStringAsFixed(1) : '—'}',
                onTap: onSubmit,
                mintStyle: true),
          ),
        ],
      ),
    );
  }
}
