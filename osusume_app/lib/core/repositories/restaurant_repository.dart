import '../models/restaurant.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getNearby({
    required double lat,
    required double lng,
    int radiusM = 2000,
    String? filter,
  });

  Future<Restaurant?> getById(String id);

  Future<List<Restaurant>> search(String query, {double? lat, double? lng});
}
