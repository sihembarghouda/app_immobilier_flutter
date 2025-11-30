import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class LocationProvider with ChangeNotifier {
  double? _latitude;
  double? _longitude;
  double _searchRadius = 5.0; // km

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  double get searchRadius => _searchRadius;

  bool get hasLocation => _latitude != null && _longitude != null;

  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void setSearchRadius(double radius) {
    _searchRadius = radius;
    notifyListeners();
  }

  void clearLocation() {
    _latitude = null;
    _longitude = null;
    notifyListeners();
  }

  // Calculate distance between two points in km
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  // Get current device location
  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setLocation(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }
}
