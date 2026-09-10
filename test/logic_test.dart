import 'package:flutter_test/flutter_test.dart';

import 'package:smac_comp/data.dart';
import 'package:smac_comp/logic.dart';
import 'package:smac_comp/models.dart';

Restaurant _r(String id, String city, List<String> tags, {double rating = 4.5}) => Restaurant(
      id: id,
      name: 'Spot $id',
      cuisine: 'Other',
      rating: rating,
      price: 'AED 30–60',
      priceNum: 45,
      distance: '—',
      distanceNum: 0,
      wait: '~15 min',
      waitNum: 15,
      tags: tags,
      dietary: [],
      seating: ['Indoor'],
      languages: ['English'],
      accessibility: [],
      image: '',
      desc: '',
      hours: '',
      city: city,
      address: city,
      lat: '',
    );

void main() {
  test('stars render filled/empty counts correctly', () {
    expect(stars(5), '★★★★★');
    expect(stars(4), '★★★★☆');
    expect(stars(0), '☆☆☆☆☆');
    expect(starsDouble(4.7), '★★★★★');
    expect(starsDouble(4.5), '★★★★★');
    expect(starsDouble(4.0), '★★★★☆');
    expect(starsDouble(3.3), '★★★☆☆');
  });

  test('emirateOf matches city strings', () {
    expect(emirateOf(_r('a', 'Abu Dhabi, UAE', [])), 'Abu Dhabi');
    expect(emirateOf(_r('b', 'Dubai', [])), 'Dubai');
    expect(emirateOf(_r('c', 'Ras Al Khaimah, UAE', [])), 'Ras Al Khaimah');
    expect(emirateOf(_r('d', 'Somewhere else', [])), '');
  });

  test('emirate filter narrows the list', () {
    final all = [
      _r('a', 'Abu Dhabi, UAE', []),
      _r('b', 'Dubai, UAE', []),
      _r('c', 'Dubai Marina', []),
    ];
    final f = Filters()..emirate = 'Dubai';
    final out = getFiltered(all, search: '', quick: 'all', filters: f);
    expect(out.map((r) => r.id), ['b', 'c']);
    expect(getFiltered(all, search: '', quick: 'all', filters: Filters()).length, 3);
  });

  test('quick filter matches tags and sorts by rating', () {
    final all = [
      _r('a', 'Abu Dhabi, UAE', ['Halal'], rating: 4.2),
      _r('b', 'Dubai, UAE', ['Quiet'], rating: 4.9),
      _r('c', 'Dubai, UAE', ['Halal', 'Quiet'], rating: 4.6),
    ];
    final out = getFiltered(all, search: '', quick: 'Halal', filters: Filters());
    expect(out.map((r) => r.id), ['c', 'a']);
  });

  test('search matches name, cuisine, tags and description', () {
    final all = [
      _r('a', 'Abu Dhabi, UAE', []),
      _r('b', 'Dubai, UAE', []),
    ];
    all[1] = Restaurant(
      id: 'b', name: 'Sakura Sushi', cuisine: 'Japanese', rating: 4.6,
      price: 'AED 40–80', priceNum: 60, distance: '—', distanceNum: 0,
      wait: '~20 min', waitNum: 20, tags: const [], dietary: const [],
      seating: const ['Indoor'], languages: const ['English'], accessibility: const [],
      image: '', desc: '', hours: '', city: 'Dubai, UAE', address: '', lat: '',
    );
    expect(getFiltered(all, search: 'sushi', quick: 'all', filters: Filters()).map((r) => r.id), ['b']);
    expect(getFiltered(all, search: 'japanese', quick: 'all', filters: Filters()).map((r) => r.id), ['b']);
  });

  test('local scoring caps hard dietary failures at 58', () {
    final veg = _r('v', 'Dubai, UAE', ['Vegetarian options'], rating: 5.0);
    veg.dietary.add('Vegetarian');
    final meat = _r('m', 'Dubai, UAE', [], rating: 5.0);
    final eater = FamilyMember(id: '1', name: 'Mom', dietary: ['Vegetarian']);
    final scored = scoreLocally('', [eater], [veg, meat], [], '');
    expect(scored.first.r.id, 'v');
    final fail = scored.firstWhere((s) => s.r.id == 'm');
    expect(fail.hardFail, isTrue);
    expect(fail.match, lessThanOrEqualTo(58));
  });

  test('local scoring rewards emirate mentioned in query', () {
    final ab = _r('a', 'Abu Dhabi, UAE', [], rating: 4.5);
    final dx = _r('b', 'Dubai, UAE', [], rating: 4.5);
    final scored = scoreLocally('somewhere in dubai', [], [ab, dx], [], '');
    expect(scored.first.r.id, 'b');
  });

  test('kEmirates covers all seven', () {
    expect(kEmirates.length, 7);
    expect(kEmirates.first, 'Abu Dhabi');
    expect(kEmirates.last, 'Fujairah');
  });

  test('cap capitalizes display names', () {
    expect(cap('laffah'), 'Laffah');
    expect(cap(''), '');
  });

  test('Under AED 50 quick chip matches price, not just tags', () {
    final cheapNoTag = _r('a', 'Dubai, UAE', ['Quiet']);
    cheapNoTag.priceNum = 30;
    cheapNoTag.price = 'AED ~30';
    final pricey = _r('b', 'Dubai, UAE', []);
    pricey.priceNum = 120;
    pricey.price = 'AED 100–140';
    final out = getFiltered([cheapNoTag, pricey], search: '', quick: 'Under AED 50', filters: Filters());
    expect(out.map((r) => r.id), ['a']);
  });

  test('favoritesOnly narrows to favorited ids', () {
    final all = [_r('a', 'Dubai, UAE', []), _r('b', 'Dubai, UAE', [])];
    final f = Filters()..favoritesOnly = true;
    expect(
      getFiltered(all, search: '', quick: 'all', filters: f, favorites: {'b'}).map((r) => r.id),
      ['b'],
    );
    expect(
      getFiltered(all, search: '', quick: 'all', filters: f, favorites: {}),
      isEmpty,
    );
  });

  test('activeCount counts all filter dimensions', () {
    final f = Filters();
    expect(f.activeCount, 0);
    f.emirate = 'Dubai';
    f.cuisines.add('Italian');
    f.favoritesOnly = true;
    expect(f.activeCount, 3);
    f.clear();
    expect(f.activeCount, 0);
  });
}
