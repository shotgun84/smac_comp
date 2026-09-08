import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

Map<String, String> get _sbHeaders => {
      'apikey': kSupabaseAnonKey,
      'Authorization': 'Bearer $kSupabaseAnonKey',
      'Content-Type': 'application/json',
    };

double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

List<String> _strList(dynamic v) =>
    (v as List?)?.map((e) => e.toString()).toList() ?? [];

Restaurant restaurantFromRow(Map<String, dynamic> w) => Restaurant(
      id: w['id']?.toString() ?? '',
      name: w['name']?.toString() ?? '',
      cuisine: w['cuisine']?.toString() ?? '',
      rating: _num(w['rating']),
      price: w['price']?.toString() ?? '',
      priceNum: _num(w['price_num']),
      distance: w['distance']?.toString() ?? '',
      distanceNum: _num(w['distance_num']),
      wait: w['wait_text']?.toString() ?? '',
      waitNum: _num(w['wait_num']),
      tags: _strList(w['tags']),
      dietary: _strList(w['dietary']),
      seating: _strList(w['seating']),
      languages: _strList(w['languages']),
      accessibility: _strList(w['accessibility']),
      image: w['image']?.toString() ?? '',
      desc: w['descr']?.toString() ?? '',
      hours: w['hours']?.toString() ?? '',
      city: w['city']?.toString() ?? '',
      address: w['address']?.toString() ?? '',
      lat: w['lat']?.toString() ?? '',
      mapsUrl: w['maps_url']?.toString() ?? '',
    );

Map<String, dynamic> restaurantToRow(Restaurant r) => {
      'id': r.id,
      'name': r.name,
      'cuisine': r.cuisine,
      'rating': r.rating,
      'price': r.price,
      'price_num': r.priceNum,
      'distance': r.distance,
      'distance_num': r.distanceNum,
      'wait_text': r.wait,
      'wait_num': r.waitNum,
      'tags': r.tags,
      'dietary': r.dietary,
      'seating': r.seating,
      'languages': r.languages,
      'accessibility': r.accessibility,
      'image': r.image,
      'descr': r.desc,
      'hours': r.hours,
      'city': r.city,
      'address': r.address,
      'lat': r.lat,
      'maps_url': r.mapsUrl,
      'sort_order': 0,
    };

FamilyReview reviewFromRow(Map<String, dynamic> w) => FamilyReview(
      id: w['id']?.toString() ?? '',
      restaurantId: w['restaurant_id']?.toString() ?? '',
      familyName: w['family_name']?.toString() ?? '',
      overall: _num(w['overall']),
      createdAt: w['created_at']?.toString() ?? '',
      members: ((w['members'] as List?) ?? [])
          .map((m) => MemberReview(
                name: (m as Map)['name']?.toString() ?? '',
                rating: ((m)['rating'] as num?)?.toInt() ?? 0,
                comment: (m)['comment']?.toString() ?? '',
                tags: _strList((m)['tags']),
              ))
          .toList(),
    );

Map<String, dynamic> reviewToRow(FamilyReview rv) => {
      'id': rv.id,
      'restaurant_id': rv.restaurantId,
      'family_name': rv.familyName,
      'overall': rv.overall,
      'created_at': rv.createdAt,
      'members': rv.members
          .map((m) => {'name': m.name, 'rating': m.rating, 'comment': m.comment, 'tags': m.tags})
          .toList(),
    };

Future<List<Restaurant>> fetchRestaurants() async {
  final res = await http
      .get(
        Uri.parse('$kSupabaseUrl/rest/v1/restaurants?select=*&order=sort_order.asc'),
        headers: _sbHeaders,
      )
      .timeout(const Duration(seconds: 9));
  if (res.statusCode != 200) throw Exception('Supabase ${res.statusCode}');
  final data = jsonDecode(res.body);
  if (data is! List) return [];
  return data.map((w) => restaurantFromRow((w as Map).cast<String, dynamic>())).toList();
}

Future<List<FamilyReview>> fetchReviews() async {
  final res = await http
      .get(
        Uri.parse('$kSupabaseUrl/rest/v1/family_reviews?select=*'),
        headers: _sbHeaders,
      )
      .timeout(const Duration(seconds: 9));
  if (res.statusCode != 200) throw Exception('Supabase ${res.statusCode}');
  final data = jsonDecode(res.body);
  if (data is! List) return [];
  return data.map((w) => reviewFromRow((w as Map).cast<String, dynamic>())).toList();
}

Future<bool> saveRestaurant(Restaurant r) async {
  try {
    final res = await http
        .post(
          Uri.parse('$kSupabaseUrl/rest/v1/restaurants'),
          headers: _sbHeaders,
          body: jsonEncode(restaurantToRow(r)),
        )
        .timeout(const Duration(seconds: 9));
    return res.statusCode >= 200 && res.statusCode < 300;
  } catch (_) {
    return false;
  }
}

Future<bool> saveReview(FamilyReview rv) async {
  try {
    final res = await http
        .post(
          Uri.parse('$kSupabaseUrl/rest/v1/family_reviews'),
          headers: _sbHeaders,
          body: jsonEncode(reviewToRow(rv)),
        )
        .timeout(const Duration(seconds: 9));
    return res.statusCode >= 200 && res.statusCode < 300;
  } catch (_) {
    return false;
  }
}

Future<List<Scored>> getGptRecommendations({
  required String query,
  required List<FamilyMember> eaters,
  required List<Restaurant> restaurants,
}) async {
  final restaurantsCompact = restaurants
      .map((r) => {
            'id': r.id,
            'name': r.name,
            'cuisine': r.cuisine,
            'rating': r.rating,
            'price': r.price,
            'priceNum': r.priceNum,
            'wait': r.wait,
            'tags': r.tags,
            'dietary': r.dietary,
            'seating': r.seating,
            'languages': r.languages,
          })
      .toList();
  final eatersCompact = eaters
      .map((m) => {'name': m.name, 'dietary': m.dietary, 'allergies': m.allergies, 'prefs': m.prefs})
      .toList();
  if (eatersCompact.isEmpty) {
    eatersCompact.add({'name': 'Generic family', 'dietary': <String>[], 'allergies': <String>[], 'prefs': <String>[]});
  }

  const system = 'You are Familia AI, a family restaurant recommender. You MUST ONLY use restaurants from the provided database — never hallucinate. Ranking priority: 1) HARD: dietary/allergies (vegetarian/vegan/halal/gluten-free and allergies gluten/nuts/dairy/seafood/shellfish/eggs — if a restaurant violates a hard requirement, cap match ≤58% and add warning), 2) user\'s explicit request (cheap/outdoor/quiet/family/kids/vegetarian/gluten/fast/dessert), 3) soft preferences (outdoor/quiet/cheap/family friendly/kids menu/fast service), 4) history/rating tie-break. Output strict JSON: {"recommendations":[{"id":"anatolia","match":94,"reasons":["✓ Vegetarian for Mom","✓ Within price range"],"warning":null}], "explanation":"short"} with exactly 3 recommendations sorted best first, match 0-100, reasons 3-5 short bullets each starting with ✓, warning string if hard fail else null. Use restaurant ids exactly as given.';
  final user = 'User query: "${query.isEmpty ? '(no specific request — use preferences)' : query}"\n\nRestaurants JSON: ${jsonEncode(restaurantsCompact)}\n\nEaters JSON: ${jsonEncode(eatersCompact)}\n\nReturn 3 recommendations.';

  final res = await http
      .post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $kOpenAiKey'},
        body: jsonEncode({
          'model': kOpenAiModel,
          'temperature': 0.35,
          'max_tokens': 900,
          'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'system', 'content': system},
            {'role': 'user', 'content': user},
          ],
        }),
      )
      .timeout(const Duration(seconds: 6));

  if (res.statusCode != 200) {
    throw Exception('OpenAI ${res.statusCode}: ${res.body.length > 160 ? res.body.substring(0, 160) : res.body}');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  final content = ((data['choices'] as List?)?.firstOrNull as Map?)?['message']?['content']?.toString();
  if (content == null || content.isEmpty) throw Exception('Empty GPT response');

  Map<String, dynamic> parsed;
  try {
    parsed = jsonDecode(content) as Map<String, dynamic>;
  } catch (_) {
    final m = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    if (m == null) rethrow;
    parsed = jsonDecode(m.group(0)!) as Map<String,dynamic>;
  }
  final recs = parsed['recommendations'];
  if (recs is! List) throw Exception('Invalid GPT JSON');

  final byId = {for (final r in restaurants) r.id: r};
  final mapped = <Scored>[];
  for (final rec in recs) {
    final map = (rec as Map).cast<String, dynamic>();
    final r = byId[map['id']?.toString()];
    if (r == null) continue;
    final match = (((map['match'] as num?)?.round() ?? 70).clamp(22, 98));
    final reasons = ((map['reasons'] as List?)?.map((e) => e.toString()).take(5).toList()) ?? [];
    final warning = map['warning']?.toString();
    final hardFail = (warning != null && warning.isNotEmpty) || match <= 58;
    mapped.add(Scored(
      r: r,
      score: match.toDouble(),
      match: match,
      reasons: reasons,
      blocks: (warning != null && warning.isNotEmpty) ? [warning] : [],
      hardFail: hardFail,
    ));
  }
  if (mapped.length < 2) throw Exception('GPT returned too few valid');
  return mapped.take(3).toList();
}
