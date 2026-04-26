import 'package:latlong2/latlong.dart';
import 'remote/restaurant_photo_model.dart';

class Restaurant {
  final String id;
  final String nameEn;
  final String nameJa;
  final String cuisine;
  final String neighborhood;
  final String address;
  final double rating;
  final int reviewCount;
  final int priceLevel;
  final double distanceKm;
  final bool isOpen;
  final String? imageUrl;
  final List<RestaurantPhoto> photos;
  final ForeignerFactors foreignerFactors;
  final String? description;
  final List<String> tags;
  final String? recommendationReason;
  final LatLng location;

  const Restaurant({
    required this.id,
    required this.nameEn,
    required this.nameJa,
    required this.cuisine,
    required this.neighborhood,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.priceLevel,
    required this.distanceKm,
    required this.isOpen,
    required this.foreignerFactors,
    required this.location,
    this.imageUrl,
    this.photos = const [],
    this.description,
    this.tags = const [],
    this.recommendationReason,
  });

  String get priceString => '¥' * priceLevel;

  String get distanceString {
    if (distanceKm < 1) return '${(distanceKm * 1000).round()}m';
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  String get walkTimeString {
    final minutes = (distanceKm * 12).round();
    return '$minutes min walk';
  }
}

class ForeignerFactors {
  final bool? englishMenu;
  final bool? englishStaff;
  final bool? cardPayment;
  final bool? suicaPayment;
  final bool? reservationRequired;
  final bool? walkInFriendly;
  final bool? allergyFriendly;
  final bool? vegetarianOptions;
  final bool? veganOptions;
  final bool? halalOptions;
  final bool? soloFriendly;
  final bool? kidFriendly;
  final int easeScore;
  final int touristTrapRisk;
  final int localGemScore;

  const ForeignerFactors({
    this.englishMenu,
    this.englishStaff,
    this.cardPayment,
    this.suicaPayment,
    this.reservationRequired,
    this.walkInFriendly,
    this.allergyFriendly,
    this.vegetarianOptions,
    this.veganOptions,
    this.halalOptions,
    this.soloFriendly,
    this.kidFriendly,
    required this.easeScore,
    this.touristTrapRisk = 3,
    this.localGemScore = 5,
  });
}

class MockRestaurants {
  static const List<Restaurant> all = [
    Restaurant(
      id: '1',
      nameEn: 'Ichiran Shibuya',
      nameJa: '一蘭 渋谷店',
      cuisine: 'Ramen',
      neighborhood: 'Shibuya',
      address: '1-22-7 Jinnan, Shibuya-ku',
      rating: 4.6,
      reviewCount: 3241,
      priceLevel: 2,
      distanceKm: 0.4,
      isOpen: true,
      tags: ['Solo-friendly', 'No Japanese needed', 'Late night'],
      recommendationReason:
          'Perfect for solo travelers. You order via a form — zero Japanese needed. Famous tonkotsu broth, private booth seating.',
      location: LatLng(35.6612, 139.6979),
      foreignerFactors: ForeignerFactors(
        englishMenu: true,
        englishStaff: false,
        cardPayment: true,
        suicaPayment: true,
        reservationRequired: false,
        walkInFriendly: true,
        soloFriendly: true,
        kidFriendly: false,
        easeScore: 95,
        touristTrapRisk: 4,
        localGemScore: 7,
      ),
    ),
    Restaurant(
      id: '2',
      nameEn: 'Sushi Saito',
      nameJa: '鮨 さいとう',
      cuisine: 'Sushi',
      neighborhood: 'Minato',
      address: '1-9-15 Nishi-Azabu, Minato-ku',
      rating: 4.9,
      reviewCount: 412,
      priceLevel: 4,
      distanceKm: 1.8,
      isOpen: true,
      tags: ['Worth the reservation', 'Omakase', 'Special occasion'],
      recommendationReason:
          'One of Tokyo\'s most celebrated sushi counters. Reservation required months in advance.',
      location: LatLng(35.6598, 139.7274),
      foreignerFactors: ForeignerFactors(
        englishMenu: false,
        englishStaff: false,
        cardPayment: false,
        reservationRequired: true,
        walkInFriendly: false,
        soloFriendly: false,
        kidFriendly: false,
        easeScore: 28,
        touristTrapRisk: 1,
        localGemScore: 10,
      ),
    ),
    Restaurant(
      id: '3',
      nameEn: 'Torikizoku Shinjuku',
      nameJa: 'とりきぞく 新宿',
      cuisine: 'Yakitori',
      neighborhood: 'Shinjuku',
      address: '3-2-1 Shinjuku, Shinjuku-ku',
      rating: 4.1,
      reviewCount: 1892,
      priceLevel: 1,
      distanceKm: 0.7,
      isOpen: true,
      tags: ['Budget', 'Late night', 'Local favorite'],
      recommendationReason:
          'Every skewer is ¥328. Lively izakaya energy, pictured menu makes ordering easy.',
      location: LatLng(35.6896, 139.7006),
      foreignerFactors: ForeignerFactors(
        englishMenu: false,
        englishStaff: false,
        cardPayment: true,
        reservationRequired: false,
        walkInFriendly: true,
        soloFriendly: true,
        kidFriendly: false,
        easeScore: 62,
        touristTrapRisk: 2,
        localGemScore: 8,
      ),
    ),
    Restaurant(
      id: '4',
      nameEn: 'bills Omotesando',
      nameJa: 'ビルズ 表参道',
      cuisine: 'Café / Brunch',
      neighborhood: 'Omotesando',
      address: '4-12-10 Jingumae, Shibuya-ku',
      rating: 4.2,
      reviewCount: 2108,
      priceLevel: 3,
      distanceKm: 1.1,
      isOpen: true,
      tags: ['English menu', 'Card accepted', 'Instagrammable'],
      recommendationReason:
          'Australian brunch favorite with full English menu and staff. Ricotta hotcakes are legendary.',
      location: LatLng(35.6654, 139.7076),
      foreignerFactors: ForeignerFactors(
        englishMenu: true,
        englishStaff: true,
        cardPayment: true,
        reservationRequired: false,
        walkInFriendly: true,
        soloFriendly: true,
        kidFriendly: true,
        easeScore: 98,
        touristTrapRisk: 5,
        localGemScore: 4,
      ),
    ),
    Restaurant(
      id: '5',
      nameEn: 'Afuri Harajuku',
      nameJa: 'AFURI 原宿',
      cuisine: 'Ramen',
      neighborhood: 'Harajuku',
      address: '6-35-3 Jingumae, Shibuya-ku',
      rating: 4.4,
      reviewCount: 1567,
      priceLevel: 2,
      distanceKm: 0.9,
      isOpen: true,
      tags: ['Vegan options', 'English menu', 'Modern'],
      recommendationReason:
          'Light yuzu shio ramen unlike anything else in Tokyo. Vegan broth available. English touch-screen ordering.',
      location: LatLng(35.6692, 139.7038),
      foreignerFactors: ForeignerFactors(
        englishMenu: true,
        englishStaff: true,
        cardPayment: true,
        suicaPayment: false,
        reservationRequired: false,
        walkInFriendly: true,
        allergyFriendly: true,
        vegetarianOptions: true,
        veganOptions: true,
        soloFriendly: true,
        kidFriendly: false,
        easeScore: 91,
        touristTrapRisk: 3,
        localGemScore: 7,
      ),
    ),
    Restaurant(
      id: '6',
      nameEn: 'Tempura Kondo',
      nameJa: '天ぷら近藤',
      cuisine: 'Tempura',
      neighborhood: 'Ginza',
      address: '9-7-6 Ginza, Chuo-ku',
      rating: 4.7,
      reviewCount: 863,
      priceLevel: 4,
      distanceKm: 2.3,
      isOpen: false,
      tags: ['Special occasion', 'Counter dining', 'Reservation recommended'],
      recommendationReason:
          'Legendary vegetable tempura. The sweet potato is a revelation. Worth every yen.',
      location: LatLng(35.6694, 139.7640),
      foreignerFactors: ForeignerFactors(
        englishMenu: true,
        englishStaff: false,
        cardPayment: true,
        reservationRequired: true,
        walkInFriendly: false,
        soloFriendly: true,
        allergyFriendly: true,
        easeScore: 72,
        touristTrapRisk: 2,
        localGemScore: 9,
      ),
    ),
    Restaurant(
      id: '7',
      nameEn: 'Gyukatsu Motomura',
      nameJa: '牛かつもと村',
      cuisine: 'Gyukatsu',
      neighborhood: 'Shibuya',
      address: '2-29-5 Dogenzaka, Shibuya-ku',
      rating: 4.3,
      reviewCount: 4102,
      priceLevel: 2,
      distanceKm: 0.6,
      isOpen: true,
      tags: ['Beef cutlet', 'Cook-it-yourself', 'Popular'],
      recommendationReason:
          'Rare beef cutlet you grill yourself on a personal stone. Photo menu, easy ordering, always a queue.',
      location: LatLng(35.6583, 139.6972),
      foreignerFactors: ForeignerFactors(
        englishMenu: true,
        englishStaff: false,
        cardPayment: true,
        reservationRequired: false,
        walkInFriendly: true,
        soloFriendly: true,
        allergyFriendly: false,
        easeScore: 84,
        touristTrapRisk: 3,
        localGemScore: 6,
      ),
    ),
    Restaurant(
      id: '8',
      nameEn: 'Narisawa',
      nameJa: 'ナリサワ',
      cuisine: 'Innovative',
      neighborhood: 'Minami-Aoyama',
      address: '2-6-15 Minami-Aoyama, Minato-ku',
      rating: 4.9,
      reviewCount: 318,
      priceLevel: 4,
      distanceKm: 1.4,
      isOpen: true,
      tags: ['Michelin 2★', 'Tasting menu', 'Nature-inspired'],
      recommendationReason:
          'Consistently ranked among Asia\'s 50 Best. Chef Yoshihiro Narisawa\'s innovative Japanese cuisine.',
      location: LatLng(35.6636, 139.7175),
      foreignerFactors: ForeignerFactors(
        englishMenu: true,
        englishStaff: true,
        cardPayment: true,
        reservationRequired: true,
        walkInFriendly: false,
        soloFriendly: false,
        allergyFriendly: true,
        easeScore: 80,
        touristTrapRisk: 1,
        localGemScore: 10,
      ),
    ),
  ];
}
