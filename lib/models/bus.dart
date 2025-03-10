import 'package:latlong2/latlong.dart';

class Bus {
  final String id;
  final String routeName;
  final String busNumber;
  final LatLng position;
  final double heading; // in degrees, 0 is north, 90 is east
  final double speed; // in km/h
  final String nextStop;
  final int etaMinutes; // estimated time of arrival to next stop in minutes
  final double distanceToNextStop; // in meters

  Bus({
    required this.id,
    required this.routeName,
    required this.busNumber,
    required this.position,
    required this.heading,
    required this.speed,
    required this.nextStop,
    required this.etaMinutes,
    required this.distanceToNextStop,
  });

  // Create a copy of this bus with updated properties
  Bus copyWith({
    String? id,
    String? routeName,
    String? busNumber,
    LatLng? position,
    double? heading,
    double? speed,
    String? nextStop,
    int? etaMinutes,
    double? distanceToNextStop,
  }) {
    return Bus(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      busNumber: busNumber ?? this.busNumber,
      position: position ?? this.position,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      nextStop: nextStop ?? this.nextStop,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceToNextStop: distanceToNextStop ?? this.distanceToNextStop,
    );
  }
} 