import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  static Future<Position?> currentPosition() async {
    final ok = await _ensurePermission();
    if (!ok) {
      try { return await Geolocator.getLastKnownPosition(); } catch (_) { return null; }
    }
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (_) {
      try { return await Geolocator.getLastKnownPosition(); } catch (_) { return null; }
    }
  }

  static Stream<Position>? positionStream({int distanceFilter = 25}) {
    // Returns a stream if permissions are granted; otherwise null
    try {
      final settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      );
      return Geolocator.getPositionStream(locationSettings: settings);
    } catch (_) {
      return null;
    }
  }
}
