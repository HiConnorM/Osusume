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
  final ForeignerFactors foreignerFactors;
  final String? description;
  final List<String> tags;
  final String? recommendationReason;

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
    this.imageUrl,
    this.description,
    this.tags = const [],
    this.recommendationReason,
  });

  String get priceString => '¥' * priceLevel;

  String get distanceString {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  String get walkTimeString {
    final minutes = (distanceKm * 12).round();
    return '${minutes} min walk';
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
  final int easeScore; // 0–100
  final int touristTrapRisk; // 0–10
  final int localGemScore; // 0–10

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

// Mock data for prototype
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
          'One of Tokyo\'s most celebrated sushi counters. Reservation required months in advance — hotel concierge recommended.',
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
      nameEn: 'Torikizoku',
      nameJa: 'とりきぞく',
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
          'Every skewer is ¥328. Lively izakaya energy, all-you-can-drink options. Pictured menu makes ordering easy.',
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
          'Australian brunch favorite with full English menu and staff. Ricotta hotcakes are legendary. Easy for anyone.',
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
  ];
}
