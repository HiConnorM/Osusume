import 'package:geolocator/geolocator.dart';
import '../models/remote/restaurant_remote_model.dart';
import '../models/restaurant.dart';
import '../network/supabase_service.dart';
import 'restaurant_repository.dart';

class SupabaseRestaurantRepository implements RestaurantRepository {
  const SupabaseRestaurantRepository();

  @override
  Future<List<Restaurant>> getNearby({
    required double lat,
    required double lng,
    int radiusM = 2000,
    String? filter,
  }) async {
    final result = await SupabaseService.invoke('search-restaurants', body: {
      'lat': lat,
      'lng': lng,
      'radiusM': radiusM,
      if (filter != null && filter != 'all') 'filter': filter,
    });

    if (result == null) return [];

    final list = (result['restaurants'] as List<dynamic>? ?? []);
    return list.map((json) {
      final remote = RestaurantRemoteModel.fromJson(json as Map<String, dynamic>);
      final distM = Geolocator.distanceBetween(lat, lng, remote.latitude, remote.longitude);
      return remote.toRestaurant(distanceKm: distM / 1000);
    }).toList();
  }

  @override
  Future<Restaurant?> getById(String id) async {
    final result = await SupabaseService.invoke('restaurant-detail', body: {'restaurantId': id});
    if (result == null) return null;

    final restaurantJson = result['restaurant'] as Map<String, dynamic>?;
    if (restaurantJson == null) return null;

    final photosJson = result['photos'] as List<dynamic>? ?? [];
    final ffJson = result['foreignerFactors'] as Map<String, dynamic>?;

    final remote = RestaurantRemoteModel.fromJson({
      ...restaurantJson,
      'photos': photosJson,
      'foreignerFactors': ?ffJson,
    });

    return remote.toRestaurant();
  }

  @override
  Future<List<Restaurant>> search(String query, {double? lat, double? lng}) async {
    final result = await SupabaseService.invoke('search-restaurants', body: {
      'lat': lat ?? 35.6580,
      'lng': lng ?? 139.7016,
      'query': query,
      'radiusM': 10000,
    });

    if (result == null) return [];

    final list = (result['restaurants'] as List<dynamic>? ?? []);
    return list.map((json) {
      final remote = RestaurantRemoteModel.fromJson(json as Map<String, dynamic>);
      return remote.toRestaurant();
    }).toList();
  }
}
