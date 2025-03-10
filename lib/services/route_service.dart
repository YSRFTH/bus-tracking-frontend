import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  // You need to sign up for a free API key at https://openrouteservice.org/dev/#/signup
  // Replace this with your actual API key
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const String baseUrl = 'https://api.openrouteservice.org/v2/directions/';

  // Get route between two points
  static Future<List<LatLng>?> getRoute(LatLng start, LatLng destination, {String profile = 'driving-car'}) async {
    try {
      final url = Uri.parse('$baseUrl$profile');
      
      final body = {
        'coordinates': [
          [start.longitude, start.latitude],
          [destination.longitude, destination.latitude]
        ]
      };

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
        print('Failed to get route: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  // For demo purposes, if API key is not set, return a simulated route
  static Future<List<LatLng>> getSimulatedRoute(LatLng start, LatLng destination) async {
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
      print('Error decoding route: $e');
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