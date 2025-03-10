import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../models/bus.dart';
import '../services/bus_service.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../widgets/bus_marker.dart';
import '../widgets/bus_details_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  final _busService = BusService();
  final _locationService = LocationService();
  final _panelController = PanelController();
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();
  final _destinationController = TextEditingController();
  
  Bus? _selectedBus;
  LatLng? _userLocation;
  LatLng? _destinationLocation;
  bool _isFollowingUser = true;
  bool _isSearchExpanded = false;
  bool _showDestinationInput = false;
  List<LatLng>? _selectedRoute;
  bool _isLoadingRoute = false;

  // Sample locations for demo purposes
  final List<Map<String, dynamic>> _sampleLocations = [
    {'name': 'Central Station', 'lat': 12.9716, 'lng': 77.5946},
    {'name': 'City Mall', 'lat': 12.9816, 'lng': 77.6046},
    {'name': 'University Campus', 'lat': 12.9616, 'lng': 77.5846},
    {'name': 'Tech Park', 'lat': 12.9916, 'lng': 77.6146},
    {'name': 'Hospital', 'lat': 12.9516, 'lng': 77.5746},
  ];

  @override
  void initState() {
    super.initState();
    _setupLocation();
    _busService.startBusUpdates();
  }

  Future<void> _setupLocation() async {
    final hasPermission = await _locationService.requestPermission();
    if (hasPermission) {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        setState(() => _userLocation = location);
        _mapController.move(location, 15);
      }
      _locationService.startLocationUpdates();
      _locationService.locationStream.listen((location) {
        setState(() => _userLocation = location);
        if (_isFollowingUser) {
          _mapController.move(location, _mapController.camera.zoom);
        }
      });
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    setState(() => _isLoadingRoute = true);
    
    try {
      // For demo purposes, use simulated route if API key is not set
      if (RouteService.apiKey == 'YOUR_API_KEY_HERE') {
        final route = await RouteService.getSimulatedRoute(start, end);
        setState(() {
          _selectedRoute = route;
          _isLoadingRoute = false;
        });
      } else {
        final route = await RouteService.getRoute(start, end);
        setState(() {
          _selectedRoute = route;
          _isLoadingRoute = false;
        });
      }
    } catch (e) {
      print('Error getting route: $e');
      setState(() => _isLoadingRoute = false);
    }
  }

  void _onBusSelected(Bus bus) {
    setState(() => _selectedBus = bus);
    _panelController.open();
    _mapController.move(bus.position, 15);
    _isFollowingUser = false;
    
    // Get route from user location to bus
    if (_userLocation != null) {
      _getRoute(_userLocation!, bus.position);
    }
  }

  void _setDestination(LatLng location, String name) {
    setState(() {
      _destinationLocation = location;
      _destinationController.text = name;
      _isSearchExpanded = false;
      _showDestinationInput = true;
    });
    
    _mapController.move(location, 15);
    _searchFocusNode.unfocus();
    
    // Get route from user location to destination
    if (_userLocation != null) {
      _getRoute(_userLocation!, location);
    }
  }

  void _clearDestination() {
    setState(() {
      _destinationLocation = null;
      _destinationController.text = '';
      _showDestinationInput = false;
      _selectedRoute = null;
    });
  }

  List<Widget> _buildSearchResults() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return [];
    
    return _sampleLocations
        .where((location) => 
            location['name'].toLowerCase().contains(query))
        .map((location) => ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(location['name']),
              onTap: () {
                _setDestination(
                  LatLng(location['lat'], location['lng']),
                  location['name'],
                );
              },
            ))
        .toList();
  }

  @override
  void dispose() {
    _busService.dispose();
    _locationService.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 0,
            maxHeight: 300,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            panel: _selectedBus != null
                ? BusDetailsSheet(bus: _selectedBus!)
                : const SizedBox.shrink(),
            body: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation ?? const LatLng(12.9716, 77.5946),
                initialZoom: 15,
                onTap: (_, __) {
                  _panelController.close();
                  setState(() {
                    _selectedBus = null;
                    _isSearchExpanded = false;
                    _searchFocusNode.unfocus();
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.bus_tracking_app',
                ),
                // Draw route polylines
                if (_selectedRoute != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _selectedRoute!,
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 30,
                        height: 30,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    if (_destinationLocation != null)
                      Marker(
                        point: _destinationLocation!,
                        width: 30,
                        height: 30,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ...(_busService.buses).map(
                      (bus) => Marker(
                        point: bus.position,
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () => _onBusSelected(bus),
                          child: BusMarker(
                            heading: bus.heading,
                            isSelected: bus.id == _selectedBus?.id,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search Bar
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Destination input
                if (_showDestinationInput)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 26),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              _destinationController.text,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _clearDestination,
                        ),
                      ],
                    ),
                  ),
                
                // Search bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: _isSearchExpanded ? 0 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 26),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Where to?',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _isSearchExpanded = false;
                                _searchController.clear();
                              });
                              _searchFocusNode.unfocus();
                            },
                          ),
                          border: InputBorder.none,
                        ),
                        onTap: () => setState(() => _isSearchExpanded = true),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_isSearchExpanded) ...[
                        const Divider(height: 1),
                        ..._buildSearchResults(),
                        if (_searchController.text.isNotEmpty && _buildSearchResults().isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No locations found. Try a different search.'),
                          ),
                        if (_searchController.text.isEmpty) ...[
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: const Text('Recent Searches'),
                            onTap: () {
                              // Handle recent searches
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.star),
                            title: const Text('Saved Places'),
                            onTap: () {
                              // Handle saved places
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoadingRoute)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Calculating route...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'location',
            onPressed: () {
              if (_userLocation != null) {
                _mapController.move(_userLocation!, 15);
                setState(() => _isFollowingUser = true);
              }
            },
            child: Icon(
              _isFollowingUser ? Icons.gps_fixed : Icons.gps_not_fixed,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
} 