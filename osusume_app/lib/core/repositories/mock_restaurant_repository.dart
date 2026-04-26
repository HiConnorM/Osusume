import 'package:geolocator/geolocator.dart';
import '../models/restaurant.dart';
import 'restaurant_repository.dart';

class MockRestaurantRepository implements RestaurantRepository {
  @override
  Future<List<Restaurant>> getNearby({
    required double lat,
    required double lng,
    int radiusM = 2000,
    String? filter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var results = MockRestaurants.all.map((r) {
      final distM = Geolocator.distanceBetween(lat, lng, r.location.latitude, r.location.longitude);
      return _withDistance(r, distM / 1000);
    }).where((r) => r.distanceKm * 1000 <= radiusM).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (filter == null || filter == 'all') return results;

    return results.where((r) {
      switch (filter) {
        case 'open_now':   return r.isOpen;
        case 'budget':     return r.priceLevel <= 2;
        case 'top_rated':  return r.rating >= 4.5;
        case 'easy':       return r.foreignerFactors.easeScore >= 70;
        default:           return true;
      }
    }).toList();
  }

  @override
  Future<Restaurant?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return MockRestaurants.all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Restaurant>> search(String query, {double? lat, double? lng}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return MockRestaurants.all.where((r) {
      return r.nameEn.toLowerCase().contains(q) ||
          r.nameJa.toLowerCase().contains(q) ||
          r.cuisine.toLowerCase().contains(q) ||
          r.neighborhood.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  Restaurant _withDistance(Restaurant r, double distanceKm) {
    return Restaurant(
      id: r.id,
      nameEn: r.nameEn,
      nameJa: r.nameJa,
      cuisine: r.cuisine,
      neighborhood: r.neighborhood,
      address: r.address,
      rating: r.rating,
      reviewCount: r.reviewCount,
      priceLevel: r.priceLevel,
      distanceKm: distanceKm,
      isOpen: r.isOpen,
      imageUrl: r.imageUrl,
      photos: r.photos,
      foreignerFactors: r.foreignerFactors,
      description: r.description,
      tags: r.tags,
      recommendationReason: r.recommendationReason,
      location: r.location,
    );
  }
}
