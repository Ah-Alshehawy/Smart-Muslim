import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_model.dart';

abstract class LocationService {
  static const String _savedLocationKey = 'smart_muslim_saved_location';

  /// Save location preference to SharedPreferences
  static Future<void> saveSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedLocationKey, jsonEncode(location.toJson()));
  }

  /// Load saved location preference if available
  static Future<LocationModel?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedLocationKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return LocationModel.fromJson(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Acquire current device location using GPS if permission is granted,
  /// with instant last-known position fallback and strict 3-second timeout
  /// to prevent any UI freezing on Android devices.
  static Future<LocationModel> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final saved = await getSavedLocation();
        return saved ?? LocationModel.cairo();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          final saved = await getSavedLocation();
          return saved ?? LocationModel.cairo();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final saved = await getSavedLocation();
        return saved ?? LocationModel.cairo();
      }

      // Step 1: Instant Last Known Position (0ms delay, no GPS lock required)
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final loc = LocationModel(
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
          cityName: 'موقعي الحالي',
          countryName: 'تحديد تلقائي (GPS)',
          isAutoGps: true,
        );
        await saveSelectedLocation(loc);
        return loc;
      }

      // Step 2: Fresh position request with strict 3-second timeout
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 3),
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );

      final loc = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: 'موقعي الحالي',
        countryName: 'تحديد تلقائي (GPS)',
        isAutoGps: true,
      );
      await saveSelectedLocation(loc);
      return loc;
    } catch (_) {
      final saved = await getSavedLocation();
      return saved ?? LocationModel.cairo();
    }
  }
}
