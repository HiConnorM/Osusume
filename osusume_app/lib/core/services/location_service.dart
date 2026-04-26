import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Tokyo Shibuya — used as fallback when location is unavailable.
const LatLng kTokyoFallback = LatLng(35.6580, 139.7016);

enum LocationStatus { granted, denied, deniedForever, serviceDisabled }

class LocationResult {
  final LatLng position;
  final LocationStatus status;

  const LocationResult({required this.position, required this.status});

  bool get isReal => status == LocationStatus.granted;
}

class LocationService {
  LocationService._();

  /// Returns the current position, or the Tokyo fallback if unavailable.
  /// Never throws — always returns a usable [LocationResult].
  static Future<LocationResult> resolve() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(
        position: kTokyoFallback,
        status: LocationStatus.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(
        position: kTokyoFallback,
        status: LocationStatus.deniedForever,
      );
    }

    if (permission == LocationPermission.denied) {
      return const LocationResult(
        position: kTokyoFallback,
        status: LocationStatus.denied,
      );
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LocationResult(
        position: LatLng(pos.latitude, pos.longitude),
        status: LocationStatus.granted,
      );
    } catch (_) {
      return const LocationResult(
        position: kTokyoFallback,
        status: LocationStatus.denied,
      );
    }
  }

  /// Distance in km between two points using the Haversine formula.
  static double distanceBetween(LatLng a, LatLng b) {
    final metres = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    return metres / 1000;
  }
}
