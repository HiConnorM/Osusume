import '../../core/models/restaurant.dart';

enum MapFilter { all, openNow, easyForForeigners, budget, topRated }

extension MapFilterLabel on MapFilter {
  String? get filterKey => switch (this) {
        MapFilter.all => null,
        MapFilter.openNow => 'open_now',
        MapFilter.easyForForeigners => 'easy',
        MapFilter.budget => 'budget',
        MapFilter.topRated => 'top_rated',
      };

  String get label => switch (this) {
        MapFilter.all => 'All',
        MapFilter.openNow => 'Open now',
        MapFilter.easyForForeigners => 'Easy for foreigners',
        MapFilter.budget => 'Budget friendly',
        MapFilter.topRated => 'Top rated',
      };

  String get emoji => switch (this) {
        MapFilter.all => '🗺️',
        MapFilter.openNow => '🟢',
        MapFilter.easyForForeigners => '😌',
        MapFilter.budget => '💰',
        MapFilter.topRated => '⭐',
      };
}

/// Pure function — returns a filtered + sorted list of restaurants.
List<Restaurant> applyMapFilter(
  List<Restaurant> restaurants,
  MapFilter filter,
) {
  final filtered = restaurants.where((r) => switch (filter) {
        MapFilter.all => true,
        MapFilter.openNow => r.isOpen,
        MapFilter.easyForForeigners => r.foreignerFactors.easeScore >= 70,
        MapFilter.budget => r.priceLevel <= 2,
        MapFilter.topRated => r.rating >= 4.5,
      });

  return filtered.toList()
    ..sort((a, b) => switch (filter) {
          MapFilter.topRated => b.rating.compareTo(a.rating),
          MapFilter.easyForForeigners => b.foreignerFactors.easeScore
              .compareTo(a.foreignerFactors.easeScore),
          _ => a.distanceKm.compareTo(b.distanceKm),
        });
}
