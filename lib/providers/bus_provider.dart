import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/bus.dart';
import '../services/bus_service.dart';

class BusProvider extends ChangeNotifier {
  final BusService _busService = BusService();
  List<Bus> _buses = [];
  Bus? _selectedBus;
  StreamSubscription? _busSubscription;

  BusProvider() {
    _initBusService();
  }

  List<Bus> get buses => _buses;
  Bus? get selectedBus => _selectedBus;

  void _initBusService() {
    _busService.startBusUpdates();
    _busSubscription = _busService.busStream.listen((buses) {
      _buses = buses;
      notifyListeners();
    });
  }

  void selectBus(Bus bus) {
    _selectedBus = bus;
    notifyListeners();
  }

  void clearSelectedBus() {
    _selectedBus = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _busSubscription?.cancel();
    super.dispose();
  }
} 