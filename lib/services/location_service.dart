import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final _locationController = StreamController<LatLng>.broadcast();
  Stream<LatLng> get locationStream => _locationController.stream;
  bool _isDisposed = false;
  StreamSubscription<Position>? _positionSubscription;

  Future<bool> requestPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  void startLocationUpdates() {
    // Cancel existing subscription if any
    _positionSubscription?.cancel();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25, // Update every 10 meters
      ),
    ).listen(
      (Position position) {
        _addToStream(LatLng(position.latitude, position.longitude));
      },
      onError: (error) {
        debugPrint('Error from location stream: $error');
      },
    );
  }

  // Safe method to add to stream
  void _addToStream(LatLng location) {
    if (!_isDisposed && !_locationController.isClosed) {
      _locationController.add(location);
    }
  }

  void dispose() {
    _isDisposed = true;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    if (!_locationController.isClosed) {
      _locationController.close();
    }
  }
}
