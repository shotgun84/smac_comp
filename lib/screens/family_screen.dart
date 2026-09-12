import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/familia_widgets.dart';

class FamilyScreen extends StatelessWidget {
  final String familyName;
  final List<FamilyMember> members;
  final TextEditingController nameCtrl;
  final TextEditingController pinCtrl;
  final ValueChanged<String> onName;
  final VoidCallback onAdd;
  final ValueChanged<String> onEdit;
  final VoidCallback onSaveFamily;
  final String saveNote;
  final bool loggedIn;
  final VoidCallback onSignOut;
  const FamilyScreen({
    super.key,
    required this.familyName,
    required this.members,
    required this.nameCtrl,
    required this.pinCtrl,
    required this.onName,
    required this.onAdd,
    required this.onEdit,
    required this.onSaveFamily,
    required this.saveNote,
    required this.loggedIn,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageBanner(
            title: 'Create your family',
            titleSize: 38,
            subtitle: Text(
              "Tell us who's eating with you. We'll use this to make better restaurant recommendations.",
              style: bannerSub(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 100),
            child: Column(
              children: [
                WhiteCard(
                  sharp: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Family name — optional'),
                      const SizedBox(height: 12),
                      FamiliaInput(controller: nameCtrl, hint: 'e.g. The Khan Family', maxLength: 28, onChanged: onName),
                      const SizedBox(height: 8),
                      Text('Shown on your family reviews and AI recommendations.',
                          style: GoogleFonts.workSans(fontSize: 12, color: AppColors.muted, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TintCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text('Family members',
                                        maxLines: 1,
                                        style: labelFraunces(size: 18)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.clay, borderRadius: BorderRadius.circular(8)),
                                  child: Text('${members.length}',
                                      style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('up to 10',
                              style: GoogleFonts.workSans(
                                  fontSize: 11.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (members.isEmpty)
                        Ticketed(
                          cut: 14,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.creamCard,
                              border: Border.all(color: AppColors.clayLine, width: 1.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.claySoft,
                                      border: Border.all(color: AppColors.clayLine),
                                    ),
                                    child: const Icon(Icons.restaurant_menu_outlined, size: 22, color: AppColors.rust),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text('No members yet',
                                    textAlign: TextAlign.center, style: labelFraunces(size: 17)),
                                const SizedBox(height: 6),
                                Text('Add the people you usually eat with.\nYou can skip this and add later.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.workSans(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
                              ],
                            ),
                          ),
                        )
                      else
                        ...members.asMap().entries.map((e) {
                          final idx = e.key;
                          final m = e.value;
                          final parts = <String>[];
                          if (m.dietary.isNotEmpty) parts.add(m.dietary.take(2).join(' • '));
                          if (m.allergies.isNotEmpty) parts.add('Allergy: ${m.allergies.take(2).join(', ')}');
                          if (m.prefs.isNotEmpty) parts.add(m.prefs.take(2).join(' • '));
                          final sub = parts.isEmpty ? 'No requirements — tap to edit' : parts.join('  •  ');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () => onEdit(m.id),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                                decoration: BoxDecoration(
                                  color: AppColors.creamCard,
                                  border: Border.all(color: AppColors.clayLine),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: avatarColor(idx)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        (m.name.isEmpty ? '?' : m.name[0]).toUpperCase(),
                                        style: GoogleFonts.workSans(
                                            fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(m.name.isEmpty ? 'Unnamed' : cap(m.name),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.workSans(fontSize: 13.5, fontWeight: FontWeight.w800)),
                                          Text(sub,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.workSans(fontSize: 11.5, color: AppColors.muted)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.line),
                                      ),
                                      child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.rust),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 6),
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(10),
                          color: AppColors.rust,
                          strokeWidth: 1.5,
                          dashPattern: const [6, 4],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add, size: 17),
                            label: Text('Add family member',
                                style: GoogleFonts.workSans(fontWeight: FontWeight.w700, fontSize: 14)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.rust,
                              backgroundColor: AppColors.creamCard,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.rust)),
                          Text('Requirement',
                              style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
                          const SizedBox(width: 10),
                          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.moss, width: 2))),
                          Text('Preference',
                              style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const HandDivider(),
                const SizedBox(height: 18),
                Ticketed(
                  cut: 14,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.creamCard,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Family account'),
                        const SizedBox(height: 12),
                        FamiliaInput(
                          controller: pinCtrl,
                          hint: 'Family PIN (4+ characters)',
                          maxLength: 24,
                          keyboard: TextInputType.visiblePassword,
                          obscure: true,
                        ),
                        const SizedBox(height: 8),
                        Text('Same name + PIN signs you in on any device.',
                            style: GoogleFonts.workSans(fontSize: 12, color: AppColors.muted, height: 1.4)),
                        const SizedBox(height: 16),
                        PrimaryButton(label: 'Save family', onTap: onSaveFamily),
                        if (saveNote.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(saveNote,
                              style: GoogleFonts.workSans(
                                  fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.moss)),
                        ],
                        if (loggedIn) ...[
                          const SizedBox(height: 4),
                          Center(
                            child: TextButton(
                              onPressed: onSignOut,
                              child: Text('Sign out',
                                  style: GoogleFonts.workSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.danger)),
                            ),
                          ),
                        ],
                      ],
                    ),
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
