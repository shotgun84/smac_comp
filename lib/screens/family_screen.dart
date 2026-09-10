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
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFA3B25B), Color(0xFF5FA47E), Color(0xFF2E8B6E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create your family', style: displayCaveat(size: 44, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  "Tell us who's eating with you. We'll use this to make better restaurant recommendations.",
                  style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.92), height: 1.5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
            child: Column(
              children: [
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Family name (optional)'),
                      const SizedBox(height: 10),
                      FamiliaInput(controller: nameCtrl, hint: 'e.g. The Khan Family', maxLength: 28, onChanged: onName),
                      const SizedBox(height: 8),
                      Text('Shown on your family reviews and AI recommendations.',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFA9A9B6), height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SectionLabel('Family members'),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.sageDark, borderRadius: BorderRadius.circular(8)),
                            child: Text('${members.length}',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                          const Spacer(),
                          Text('up to 10',
                              style: GoogleFonts.inter(
                                  fontSize: 11.5, color: const Color(0xFFACACB8), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (members.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE8E2DE), style: BorderStyle.solid, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFFFFCFB),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1EFEA)),
                                child: const Icon(Icons.person_add_outlined, size: 16, color: Color(0xFF8B8B97)),
                              ),
                              const SizedBox(height: 8),
                              Text('No members yet',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Add the people you usually eat with. You can skip this and add later.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF8B8B97), height: 1.4)),
                            ],
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
                                  color: AppColors.mint,
                                  border: Border.all(color: AppColors.mintBorder),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: avatarColor(idx)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        (m.name.isEmpty ? '?' : m.name[0]).toUpperCase(),
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
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
                                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                                          Text(sub,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF8B8B97))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.inputBorder),
                                      ),
                                      child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.sageDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 2),
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(10),
                          color: AppColors.mintBorder,
                          strokeWidth: 1.5,
                          dashPattern: const [6, 4],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add, size: 16),
                            label: Text('Add family member',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.sageDark,
                              backgroundColor: const Color(0xFFEDF5EA),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.reqBrown)),
                          const SizedBox(width: 4),
                          Text('REQUIREMENT   ',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sageDark)),
                          const SizedBox(width: 4),
                          Text('PREFERENCE',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Family account'),
                      const SizedBox(height: 10),
                      FamiliaInput(
                        controller: pinCtrl,
                        hint: 'Family PIN (4+ characters)',
                        maxLength: 24,
                        keyboard: TextInputType.visiblePassword,
                        obscure: true,
                      ),
                      const SizedBox(height: 6),
                      Text('Same name + PIN signs you in on any device.',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFA9A9B6), height: 1.4)),
                      const SizedBox(height: 12),
                      PrimaryButton(label: 'Save family', onTap: onSaveFamily),
                      if (saveNote.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(saveNote,
                            style: GoogleFonts.inter(
                                fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.sageDark)),
                      ],
                      if (loggedIn) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: TextButton(
                            onPressed: onSignOut,
                            child: Text('Sign out',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.danger)),
                          ),
                        ),
                      ],
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
