import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/models/restaurant.dart';
import '../../core/providers/restaurant_providers.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'map_filters.dart';
import 'widgets/restaurant_map_sheet.dart';
import 'widgets/restaurant_marker.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  LatLng _userPosition = kTokyoFallback;
  bool _locationIsReal = false;
  bool _isLoadingLocation = true;

  MapFilter _activeFilter = MapFilter.all;
  String? _selectedRestaurantId;

  List<Restaurant> get _visibleRestaurants {
    final nearby = ref.read(nearbyRestaurantsProvider).valueOrNull ?? [];
    return applyMapFilter(nearby, _activeFilter);
  }

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  Future<void> _resolveLocation() async {
    final result = await LocationService.resolve();
    if (!mounted) return;
    setState(() {
      _userPosition = result.position;
      _locationIsReal = result.isReal;
      _isLoadingLocation = false;
    });

    ref.read(nearbyParamsProvider.notifier).state = NearbyParams(
      position: result.position,
      radiusM: 2000,
      filter: _activeFilter == MapFilter.all ? null : _activeFilter.filterKey,
    );

    if (result.isReal) {
      _animateTo(result.position, zoom: 15);
    }

    if (result.status == LocationStatus.deniedForever && mounted) {
      _showLocationDeniedBanner();
    }
  }

  void _animateTo(LatLng target, {double zoom = 15}) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: target.latitude,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: target.longitude,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: zoom,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.value, lngTween.value),
        zoomTween.value,
      );
    });
    controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) controller.dispose();
    });
    controller.forward();
  }

  void _onMarkerTap(Restaurant restaurant) {
    HapticFeedback.lightImpact();
    setState(() => _selectedRestaurantId = restaurant.id);
    _animateTo(restaurant.location, zoom: 16);
    _showRestaurantSheet(restaurant);
  }

  void _onMapTap(TapPosition _, LatLng __) {
    if (_selectedRestaurantId != null) {
      setState(() => _selectedRestaurantId = null);
    }
  }

  void _showRestaurantSheet(Restaurant restaurant) {
    final distance = LocationService.distanceBetween(
      _userPosition,
      restaurant.location,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scrollController) => RestaurantMapSheet(
          restaurant: restaurant,
          distanceKm: distance,
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedRestaurantId = null);
    });
  }

  void _showLocationDeniedBanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Showing Tokyo — enable location for local results'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () => Geolocator.openAppSettings(),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          _buildFilterBar(),
          if (_isLoadingLocation) _buildLocationLoader(),
          _buildFab(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userPosition,
        initialZoom: 14.5,
        minZoom: 10,
        maxZoom: 19,
        onTap: _onMapTap,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.osusume.osusume_app',
          maxZoom: 19,
        ),
        if (_locationIsReal) _buildUserLocationLayer(),
        MarkerLayer(
          markers: _buildMarkers(),
          rotate: false,
        ),
      ],
    );
  }

  Widget _buildUserLocationLayer() {
    return MarkerLayer(
      markers: [
        Marker(
          point: _userPosition,
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return _visibleRestaurants.map((restaurant) {
      final isSelected = restaurant.id == _selectedRestaurantId;
      return Marker(
        point: restaurant.location,
        width: isSelected ? 160 : 44,
        height: 52,
        alignment: Alignment.bottomCenter,
        child: RestaurantMarker(
          restaurant: restaurant,
          isSelected: isSelected,
          onTap: () => _onMarkerTap(restaurant),
        ),
      );
    }).toList();
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            // Search / title chip
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_visibleRestaurants.length} ${_visibleRestaurants.length == 1 ? 'restaurant' : 'restaurants'} near you',
                        style: AppTextStyles.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Recenter button
            _MapButton(
              icon: _locationIsReal
                  ? Icons.my_location_rounded
                  : Icons.location_searching_rounded,
              onTap: _isLoadingLocation
                  ? null
                  : () => _animateTo(_userPosition, zoom: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 68,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: MapFilter.values.map((filter) {
            final isActive = filter == _activeFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _activeFilter = filter);
                  ref.read(nearbyParamsProvider.notifier).state = NearbyParams(
                    position: _userPosition,
                    radiusM: 2000,
                    filter: filter.filterKey,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter.emoji,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        filter.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isActive ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationLoader() {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.shadow, blurRadius: 8),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Text('Finding your location...', style: AppTextStyles.labelSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _MapButton(
            icon: Icons.add_rounded,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 8),
          _MapButton(
            icon: Icons.remove_rounded,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      left: 16,
      bottom: 100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ease score', style: AppTextStyles.caption),
            const SizedBox(height: 6),
            _LegendRow(AppColors.easeHigh, '70+  Easy'),
            _LegendRow(AppColors.warning, '40–69  Moderate'),
            _LegendRow(AppColors.easeLow, '<40  Difficult'),
            _LegendRow(AppColors.textTertiary, 'Closed'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _MapButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: onTap == null ? AppColors.textTertiary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
