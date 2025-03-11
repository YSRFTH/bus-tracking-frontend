import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  bool _isFollowingUser = true;
  StreamSubscription? _locationSubscription;
  bool _hasPermission = false;

  LocationProvider() {
    _initLocationService();
  }

  LatLng? get currentLocation => _currentLocation;
  bool get isFollowingUser => _isFollowingUser;
  bool get hasPermission => _hasPermission;

  Future<void> _initLocationService() async {
    _hasPermission = await _locationService.requestPermission();
    
    if (_hasPermission) {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        notifyListeners();
      }
      
      _locationService.startLocationUpdates();
      _locationSubscription = _locationService.locationStream.listen((location) {
        _currentLocation = location;
        notifyListeners();
      });
    }
  }

  void setFollowingUser(bool value) {
    _isFollowingUser = value;
    notifyListeners();
  }

  Future<void> requestLocationPermission() async {
    _hasPermission = await _locationService.requestPermission();
    if (_hasPermission) {
      _initLocationService();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
} 