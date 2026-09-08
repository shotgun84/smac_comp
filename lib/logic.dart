import 'package:flutter/material.dart';
import 'data.dart';
import 'models.dart';

String emirateOf(Restaurant r) {
  final city = r.city.toLowerCase();
  for (final e in kEmirates) {
    if (city.contains(e.toLowerCase())) return e;
  }
  return '';
}

String stars(int n) {
  final b = StringBuffer();
  for (var i = 1; i <= 5; i++) {
    b.write(i <= n ? '★' : '☆');
  }
  return b.toString();
}

String starsDouble(double n) => stars(n.round());

Color avatarColor(int i) {
  const palette = [
    Color(0xFF3E6B57),
    Color(0xFF5A7D6B),
    Color(0xFFB7791F),
    Color(0xFF7A9B8A),
    Color(0xFF8AA399),
    Color(0xFFA3B25B),
    Color(0xFF2F3D36),
  ];
  return palette[i % palette.length];
}

String greetingFor(String familyName) {
  final hr = DateTime.now().hour;
  final g = hr < 12 ? 'Good morning' : hr < 18 ? 'Good afternoon' : 'Good evening';
  return familyName.isEmpty ? g : '$g, $familyName';
}

List<Restaurant> getFiltered(
  List<Restaurant> all, {
  required String search,
  required String quick,
  required Filters filters,
}) {
  var list = List<Restaurant>.of(all);
  final q = search.toLowerCase().trim();
  if (q.isNotEmpty) {
    list = list
        .where((r) => ('${r.name} ${r.cuisine} ${r.tags.join(' ')} ${r.desc}').toLowerCase().contains(q))
        .toList();
  }
  if (quick != 'all') {
    final qq = quick.toLowerCase();
    list = list
        .where((r) => ('${r.tags.join(' ')} ${r.cuisine} ${r.price}').toLowerCase().contains(qq))
        .toList();
    list.sort((a, b) => b.rating.compareTo(a.rating));
  }
  if (filters.emirate != 'any') {
    list = list.where((r) => emirateOf(r) == filters.emirate).toList();
  }
  if (filters.price == 'cheap') list = list.where((r) => r.priceNum <= 50).toList();
  if (filters.price == 'mid') list = list.where((r) => r.priceNum > 50 && r.priceNum <= 100).toList();
  if (filters.rating == '4') list = list.where((r) => r.rating >= 4.5).toList();
  if (filters.rating == '4.3') list = list.where((r) => r.rating >= 4.3).toList();
  if (filters.cuisines.isNotEmpty) {
    list = list.where((r) => filters.cuisines.contains(r.cuisine)).toList();
  }
  if (filters.dietary.isNotEmpty) {
    list = list.where((r) {
      final hay = r.tags.map((t) => t.toLowerCase()).join(' ');
      return filters.dietary.every((d) => hay.contains(d.toLowerCase().split(' ').first));
    }).toList();
  }
  return list;
}

List<Scored> scoreLocally(
  String query,
  List<FamilyMember> eaters,
  List<Restaurant> restaurants,
  List<FamilyReview> reviews,
  String familyName,
) {
  final q = query.toLowerCase();
  final out = <Scored>[];
  for (final r in restaurants) {
    var score = 50.0;
    final reasons = <String>[];
    final blocks = <String>[];
    var hardFail = false;

    for (final m in eaters) {
      for (final req in m.dietary) {
        final need = req.toLowerCase();
        var ok = false;
        if (need == 'vegetarian') {
          ok = r.dietary.contains('Vegetarian') || r.tags.contains('Vegetarian options');
        } else if (need == 'vegan') {
          ok = r.dietary.contains('Vegan') || r.tags.contains('Vegan options');
        } else if (need == 'gluten-free') {
          ok = r.dietary.contains('Gluten-free') || r.tags.contains('Gluten-free');
        } else if (need == 'halal') {
          ok = r.dietary.contains('Halal') || r.tags.contains('Halal');
        } else {
          ok = r.dietary.join(' ').toLowerCase().contains(need.replaceAll('no ', '')) ||
              r.tags.join(' ').toLowerCase().contains(need);
        }
        if (!ok) {
          hardFail = true;
          blocks.add('$req needed for ${m.name} — not found');
          score -= 28;
        } else {
          score += 8;
          reasons.add('✓ $req for ${m.name}');
        }
      }
      for (final al in m.allergies) {
        final a = al.toLowerCase();
        if (a == 'gluten' &&
            !r.dietary.contains('Gluten-free') &&
            !r.tags.join(' ').toLowerCase().contains('gluten-free')) {
          hardFail = true;
          blocks.add('Gluten allergy for ${m.name}');
          score -= 30;
        } else if (a == 'nuts' && r.name == 'Casa Luna') {
          hardFail = true;
          blocks.add('Nuts allergy for ${m.name}');
          score -= 30;
        } else if (a == 'seafood' && r.cuisine == 'Japanese') {
          hardFail = true;
          blocks.add('Seafood allergy for ${m.name} — sushi');
          score -= 30;
        } else if (a == 'shellfish' && r.cuisine == 'Japanese') {
          hardFail = true;
          blocks.add('Shellfish allergy for ${m.name} — sushi');
          score -= 30;
        } else {
          reasons.add('✓ No $al issue for ${m.name}');
          score += 2;
        }
      }
    }

    if (q.isNotEmpty) {
      if (q.contains('cheap') || q.contains('inexpensive') || q.contains('not too expensive') || q.contains('under')) {
        if (r.priceNum <= 45) {
          score += 12;
          reasons.add('✓ Within your price range');
        } else {
          score -= 8;
        }
      }
      for (final e in kEmirates) {
        if (q.contains(e.toLowerCase()) && emirateOf(r) == e) {
          score += 12;
          reasons.add('✓ In $e');
        }
      }
      if (q.contains('outdoor') || q.contains('terrace') || q.contains('garden')) {
        if (r.tags.contains('Outdoor seating')) {
          score += 10;
          reasons.add('✓ Outdoor seating');
        } else {
          score -= 4;
        }
      }
      if (q.contains('quiet')) {
        if (r.tags.contains('Quiet')) {
          score += 8;
          reasons.add('✓ Quiet');
        } else {
          score -= 2;
        }
      }
      if (q.contains('family') || q.contains('kids')) {
        if (r.tags.contains('Family friendly') || r.tags.contains('Kids menu')) {
          score += 10;
          reasons.add('✓ Family friendly • Kids menu');
        }
      }
      if (q.contains('vegetarian')) {
        if (r.tags.contains('Vegetarian options') || r.dietary.contains('Vegetarian')) {
          score += 10;
          reasons.add('✓ Vegetarian options');
        }
      }
      if (q.contains('gluten')) {
        if (r.dietary.contains('Gluten-free')) {
          score += 10;
          reasons.add('✓ Gluten-free options');
        }
      }
      if (q.contains('fast') || q.contains('quick')) {
        if (r.waitNum <= 12) {
          score += 8;
          reasons.add('✓ Fast • ${r.wait}');
        }
      }
      if (q.contains('dessert')) {
        if (r.tags.contains('Good desserts')) {
          score += 7;
          reasons.add('✓ Good desserts');
        }
      }
    } else {
      for (final m in eaters) {
        for (final p in m.prefs) {
          if (p == 'Outdoor seating' && r.tags.contains('Outdoor seating')) score += 5;
          if (p == 'Quiet' && r.tags.contains('Quiet')) score += 5;
          if (p == 'Cheap' && r.priceNum <= 40) score += 5;
          if (p == 'Family friendly' && r.tags.contains('Family friendly')) score += 5;
          if (p == 'Kids menu' && r.tags.contains('Kids menu')) score += 5;
          if (p == 'Fast service' && r.waitNum <= 12) score += 4;
        }
      }
    }

    score += (r.rating - 4) * 8;
    final reviewed = reviews.any((fr) => fr.restaurantId == r.id && fr.familyName == (familyName.isEmpty ? 'Your family' : familyName));
    if (reviewed) score -= 1;

    var match = score.round().clamp(22, 98);
    if (hardFail) match = match.clamp(22, 58);
    out.add(Scored(
      r: r,
      score: score,
      match: match,
      reasons: reasons.toSet().take(6).toList(),
      blocks: blocks,
      hardFail: hardFail,
    ));
  }
  out.sort((a, b) => b.score.compareTo(a.score));
  return out;
}
