import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../config/app_config.dart';
import '../models/restaurant.dart';
import '../repositories/mock_restaurant_repository.dart';
import '../repositories/restaurant_repository.dart';
import '../repositories/supabase_restaurant_repository.dart';
import '../services/location_service.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  if (AppConfig.isSupabaseConfigured) {
    return const SupabaseRestaurantRepository();
  }
  return MockRestaurantRepository();
});

// ── Location ──────────────────────────────────────────────────────────────────

final locationProvider = FutureProvider<LocationResult>((ref) {
  return LocationService.resolve();
});

// ── Nearby restaurants ────────────────────────────────────────────────────────

class NearbyParams {
  final LatLng position;
  final int radiusM;
  final String? filter;

  const NearbyParams({
    required this.position,
    this.radiusM = 2000,
    this.filter,
  });

  @override
  bool operator ==(Object other) =>
      other is NearbyParams &&
      other.position.latitude == position.latitude &&
      other.position.longitude == position.longitude &&
      other.radiusM == radiusM &&
      other.filter == filter;

  @override
  int get hashCode => Object.hash(position.latitude, position.longitude, radiusM, filter);
}

final nearbyParamsProvider = StateProvider<NearbyParams?>((ref) => null);

final nearbyRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final locationResult = await ref.watch(locationProvider.future);
  final params = ref.watch(nearbyParamsProvider);
  final repo = ref.watch(restaurantRepositoryProvider);

  final pos = params?.position ?? locationResult.position;
  final radiusM = params?.radiusM ?? 2000;
  final filter = params?.filter;

  return repo.getNearby(
    lat: pos.latitude,
    lng: pos.longitude,
    radiusM: radiusM,
    filter: filter,
  );
});

// ── Single restaurant detail ──────────────────────────────────────────────────

final restaurantDetailProvider = FutureProvider.family<Restaurant?, String>((ref, id) async {
  final repo = ref.watch(restaurantRepositoryProvider);
  return repo.getById(id);
});

// ── Search ────────────────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = ref.watch(restaurantRepositoryProvider);
  final locationResult = await ref.watch(locationProvider.future);
  final pos = locationResult.position;

  return repo.search(query, lat: pos.latitude, lng: pos.longitude);
});
