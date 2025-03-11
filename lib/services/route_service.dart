import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RouteService {
  // Get API key from environment variables
  static String get apiKey => dotenv.env['ROUTE_API_KEY'] ?? 'YOUR_API_KEY_HERE';
  static const String baseUrl = 'https://api.openrouteservice.org/v2/directions/';

  // Get route between two points
  static Future<List<LatLng>?> getRoute(LatLng start, LatLng destination, {String profile = 'driving-car'}) async {
    // If API key is not set, use simulated route
    if (apiKey == 'YOUR_API_KEY_HERE') {
      debugPrint('API key not set, using simulated route');
      return getSimulatedRoute(start, destination);
    }
    
    try {
      final url = Uri.parse('$baseUrl$profile');
      
      final body = {
        'coordinates': [
          [start.longitude, start.latitude],
          [destination.longitude, destination.latitude]
        ]
      };

      debugPrint('Requesting route from ${start.latitude},${start.longitude} to ${destination.latitude},${destination.longitude}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': apiKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _decodeRoute(data);
      } else {
        debugPrint('Failed to get route: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return getSimulatedRoute(start, destination);
      }
    } catch (e) {
      debugPrint('Error getting route: $e');
      return getSimulatedRoute(start, destination);
    }
  }

  // For demo purposes, if API key is not set, return a simulated route
  static Future<List<LatLng>> getSimulatedRoute(LatLng start, LatLng destination) async {
    debugPrint('Using simulated route from ${start.latitude},${start.longitude} to ${destination.latitude},${destination.longitude}');
    
    // Create a simple straight line with some points in between
    final latDiff = destination.latitude - start.latitude;
    final lngDiff = destination.longitude - start.longitude;
    
    final points = <LatLng>[];
    const steps = 5; // Number of points in the route
    
    for (int i = 0; i <= steps; i++) {
      final fraction = i / steps;
      points.add(LatLng(
        start.latitude + latDiff * fraction,
        start.longitude + lngDiff * fraction,
      ));
    }
    
    return points;
  }

  // Decode the route from the API response
  static List<LatLng>? _decodeRoute(Map<String, dynamic> data) {
    try {
      final routes = data['routes'] as List;
      if (routes.isEmpty) return null;
      
      final geometry = routes[0]['geometry'] as String;
      return _decodePolyline(geometry);
    } catch (e) {
      debugPrint('Error decoding route: $e');
      return null;
    }
  }

  // Decode the polyline string into a list of coordinates
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
} 