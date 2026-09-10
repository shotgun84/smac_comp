class Restaurant {
  String id;
  String name;
  String cuisine;
  double rating;
  String price;
  double priceNum;
  String distance;
  double distanceNum;
  String wait;
  double waitNum;
  List<String> tags;
  List<String> dietary;
  List<String> seating;
  List<String> languages;
  List<String> accessibility;
  String image;
  String desc;
  String hours;
  String city;
  String address;
  String lat;
  String mapsUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.price,
    required this.priceNum,
    required this.distance,
    required this.distanceNum,
    required this.wait,
    required this.waitNum,
    required this.tags,
    required this.dietary,
    required this.seating,
    required this.languages,
    required this.accessibility,
    required this.image,
    required this.desc,
    required this.hours,
    required this.city,
    required this.address,
    required this.lat,
    this.mapsUrl = '',
  });
}

class FamilyMember {
  String id;
  String name;
  List<String> dietary;
  List<String> allergies;
  List<String> prefs;

  FamilyMember({
    required this.id,
    required this.name,
    List<String>? dietary,
    List<String>? allergies,
    List<String>? prefs,
  })  : dietary = dietary ?? [],
        allergies = allergies ?? [],
        prefs = prefs ?? [];
}

class MemberReview {
  String name;
  int rating;
  String comment;
  List<String> tags;

  MemberReview({
    required this.name,
    required this.rating,
    this.comment = '',
    List<String>? tags,
  }) : tags = tags ?? [];
}

class FamilyReview {
  String id;
  String restaurantId;
  String familyName;
  double overall;
  String createdAt;
  List<MemberReview> members;

  FamilyReview({
    required this.id,
    required this.restaurantId,
    required this.familyName,
    required this.overall,
    required this.createdAt,
    required this.members,
  });
}

class Filters {
  String emirate;
  String price;
  String rating;
  List<String> cuisines;
  List<String> dietary;
  bool favoritesOnly;

  Filters({
    this.emirate = 'any',
    this.price = 'any',
    this.rating = 'any',
    List<String>? cuisines,
    List<String>? dietary,
    this.favoritesOnly = false,
  })  : cuisines = cuisines ?? [],
        dietary = dietary ?? [];

  Filters copy() => Filters(
        emirate: emirate,
        price: price,
        rating: rating,
        cuisines: List.of(cuisines),
        dietary: List.of(dietary),
        favoritesOnly: favoritesOnly,
      );

  void clear() {
    emirate = 'any';
    price = 'any';
    rating = 'any';
    cuisines.clear();
    dietary.clear();
    favoritesOnly = false;
  }

  int get activeCount {
    var n = 0;
    if (emirate != 'any') n++;
    if (price != 'any') n++;
    if (rating != 'any') n++;
    n += cuisines.length + dietary.length;
    if (favoritesOnly) n++;
    return n;
  }
}

class FamilyAccount {
  String name;
  String pin;
  List<FamilyMember> members;
  List<String> favorites;

  FamilyAccount({
    required this.name,
    required this.pin,
    List<FamilyMember>? members,
    List<String>? favorites,
  })  : members = members ?? [],
        favorites = favorites ?? [];
}

class Scored {
  final Restaurant r;
  final double score;
  final int match;
  final List<String> reasons;
  final List<String> blocks;
  final bool hardFail;

  Scored({
    required this.r,
    required this.score,
    required this.match,
    required this.reasons,
    required this.blocks,
    required this.hardFail,
  });
}

class NewRestaurantDraft {
  String name = '';
  String cuisine = '';
  List<String> seating = [];
  String hours = '';
  String city = 'Abu Dhabi';
  int party = 2;
  String bill = '';
  String wait = '~15 min';
  List<String> langs = [];
  List<String> access = [];
  List<String> tags = [];
  List<String> who = [];
  Map<String, int> ratings = {};
  Map<String, String> comments = {};
  String comment = '';
  bool individual = false;
  int step = 0;
  List<int> photoBytes = [];
}
