import 'dart:async';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/bus.dart';

class BusService {
  static final BusService _instance = BusService._internal();
  factory BusService() => _instance;
  BusService._internal();

  final _busController = StreamController<List<Bus>>.broadcast();
  Stream<List<Bus>> get busStream => _busController.stream;
  Timer? _timer;
  bool _isDisposed = false;

  // Simulated bus data
  List<Bus> _buses = [];
  final Random _random = Random();

  // Center point for simulated buses (adjust these coordinates for your city)
  final LatLng _center = LatLng(12.9716, 77.5946); // Example: Bangalore

  List<Bus> get buses => _buses;

  void startBusUpdates() {
    // Initialize buses with random positions
    _initializeBuses();

    // Update bus positions every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateBusPositions();
    });
  }

  void _initializeBuses() {
    for (int i = 0; i < 5; i++) {
      final id = 'BUS${i + 1}';
      final routeName = 'Route ${i + 1}';
      final position = _getRandomPosition();

      _buses.add(Bus(
        id: id,
        routeName: routeName,
        busNumber: 'KA-${_random.nextInt(99)}-B-${1000 + _random.nextInt(9000)}',
        position: position,
        heading: _random.nextDouble() * 360,
        speed: 20 + _random.nextDouble() * 40, // 20-60 km/h
        nextStop: 'Stop ${_random.nextInt(10) + 1}',
        etaMinutes: _random.nextInt(15) + 1,
        distanceToNextStop: _random.nextDouble() * 1000, // 0-1000 meters
      ));
    }
    _addToStream(_buses);
  }

  void _updateBusPositions() {
    for (int i = 0; i < _buses.length; i++) {
      final bus = _buses[i];
      final movement = _getRandomMovement();
      final newPosition = LatLng(
        bus.position.latitude + movement.latitude,
        bus.position.longitude + movement.longitude,
      );

      _buses[i] = bus.copyWith(
        position: newPosition,
        heading: _random.nextDouble() * 360,
        speed: 20 + _random.nextDouble() * 40,
        etaMinutes: _random.nextInt(15) + 1,
        distanceToNextStop: _random.nextDouble() * 1000,
      );
    }
    _addToStream(_buses);
  }

  // Safe method to add to stream
  void _addToStream(List<Bus> buses) {
    if (!_isDisposed && !_busController.isClosed) {
      _busController.add(buses);
    }
  }

  LatLng _getRandomPosition() {
    // Generate random position within ~5km of center
    final lat = _center.latitude + (_random.nextDouble() - 0.5) * 0.1;
    final lng = _center.longitude + (_random.nextDouble() - 0.5) * 0.1;
    return LatLng(lat, lng);
  }

  LatLng _getRandomMovement() {
    // Small random movement (approximately 10-50 meters)
    return LatLng(
      (_random.nextDouble() - 0.5) * 0.0005,
      (_random.nextDouble() - 0.5) * 0.0005,
    );
  }

  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    if (!_busController.isClosed) {
      _busController.close();
    }
  }
} 