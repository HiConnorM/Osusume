import 'package:latlong2/latlong.dart';
import '../restaurant.dart';
import 'restaurant_photo_model.dart';

/// Full restaurant record as returned by our Supabase backend.
/// Maps to the `restaurants` + `restaurant_foreigner_factors` + `restaurant_photos` tables.
class RestaurantRemoteModel {
  final String id;
  final String? googlePlaceId;
  final String nameEn;
  final String? nameJa;
  final String? cuisineType;
  final int priceLevel;
  final String? address;
  final String? neighborhood;
  final double latitude;
  final double longitude;
  final double? googleRating;
  final int? googleReviewCount;
  final bool? isOpenNow;
  final String? phone;
  final String? website;
  final String? googleMapsUrl;
  final List<RestaurantPhoto> photos;
  final RemoteForeignerFactors? foreignerFactors;

  const RestaurantRemoteModel({
    required this.id,
    this.googlePlaceId,
    required this.nameEn,
    this.nameJa,
    this.cuisineType,
    required this.priceLevel,
    this.address,
    this.neighborhood,
    required this.latitude,
    required this.longitude,
    this.googleRating,
    this.googleReviewCount,
    this.isOpenNow,
    this.phone,
    this.website,
    this.googleMapsUrl,
    this.photos = const [],
    this.foreignerFactors,
  });

  factory RestaurantRemoteModel.fromJson(Map<String, dynamic> json) {
    final photosList = (json['photos'] as List<dynamic>? ?? [])
        .map((p) => RestaurantPhoto.fromJson(p as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final ff = json['foreignerFactors'] as Map<String, dynamic>?;

    return RestaurantRemoteModel(
      id: json['id'] as String,
      googlePlaceId: json['google_place_id'] as String?,
      nameEn: json['name_en'] as String,
      nameJa: json['name_ja'] as String?,
      cuisineType: json['cuisine_type'] as String?,
      priceLevel: (json['price_level'] as num?)?.toInt() ?? 2,
      address: json['address'] as String?,
      neighborhood: json['neighborhood'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      googleRating: (json['google_rating'] as num?)?.toDouble(),
      googleReviewCount: (json['google_review_count'] as num?)?.toInt(),
      isOpenNow: json['is_open_now'] as bool?,
      phone: json['national_phone_number'] as String? ?? json['phone'] as String?,
      website: json['website_uri'] as String? ?? json['website'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      photos: photosList,
      foreignerFactors: ff != null ? RemoteForeignerFactors.fromJson(ff) : null,
    );
  }

  /// Convert to the app's local [Restaurant] model for use in existing UI.
  Restaurant toRestaurant({double? distanceKm}) {
    final ff = foreignerFactors;
    return Restaurant(
      id: id,
      nameEn: nameEn,
      nameJa: nameJa ?? '',
      cuisine: cuisineType ?? 'Restaurant',
      neighborhood: neighborhood ?? '',
      address: address ?? '',
      rating: googleRating ?? 0,
      reviewCount: googleReviewCount ?? 0,
      priceLevel: priceLevel,
      distanceKm: distanceKm ?? 1.0,
      isOpen: isOpenNow ?? false,
      location: LatLng(latitude, longitude),
      imageUrl: photos.firstOrNull?.displayUrl,
      photos: photos,
      foreignerFactors: ff != null
          ? ForeignerFactors(
              englishMenu: ff.englishMenu,
              englishStaff: ff.englishStaffLikely,
              cardPayment: ff.cardPayment,
              suicaPayment: ff.suicaPayment,
              reservationRequired: ff.reservationRequired,
              walkInFriendly: ff.walkInFriendly,
              allergyFriendly: ff.allergyFriendly,
              vegetarianOptions: ff.vegetarianOptions,
              veganOptions: ff.veganOptions,
              halalOptions: ff.halalOptions,
              soloFriendly: ff.soloFriendly,
              kidFriendly: ff.kidFriendly,
              easeScore: ff.easeScore ?? 50,
              touristTrapRisk: ff.touristTrapRisk ?? 3,
              localGemScore: ff.localGemScore ?? 5,
            )
          : const ForeignerFactors(easeScore: 50),
    );
  }
}

class RemoteForeignerFactors {
  final bool? englishMenu;
  final bool? englishStaffLikely;
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
  final int? easeScore;
  final int? touristTrapRisk;
  final int? localGemScore;
  final String? whatToOrder;
  final String? howToBook;
  final String? etiquetteNotes;

  const RemoteForeignerFactors({
    this.englishMenu,
    this.englishStaffLikely,
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
    this.easeScore,
    this.touristTrapRisk,
    this.localGemScore,
    this.whatToOrder,
    this.howToBook,
    this.etiquetteNotes,
  });

  factory RemoteForeignerFactors.fromJson(Map<String, dynamic> json) {
    return RemoteForeignerFactors(
      englishMenu: json['english_menu'] as bool?,
      englishStaffLikely: json['english_staff_likely'] as bool?,
      cardPayment: json['card_payment'] as bool?,
      suicaPayment: json['suica_payment'] as bool?,
      reservationRequired: json['reservation_required'] as bool?,
      walkInFriendly: json['walk_in_friendly'] as bool?,
      allergyFriendly: json['allergy_friendly'] as bool?,
      vegetarianOptions: json['vegetarian_options'] as bool?,
      veganOptions: json['vegan_options'] as bool?,
      halalOptions: json['halal_options'] as bool?,
      soloFriendly: json['solo_friendly'] as bool?,
      kidFriendly: json['kid_friendly'] as bool?,
      easeScore: (json['ease_score'] as num?)?.toInt(),
      touristTrapRisk: (json['tourist_trap_risk'] as num?)?.toInt(),
      localGemScore: (json['local_gem_score'] as num?)?.toInt(),
      whatToOrder: json['what_to_order'] as String?,
      howToBook: json['how_to_book'] as String?,
      etiquetteNotes: json['etiquette_notes'] as String?,
    );
  }
}
