import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

import 'package:geolocator/geolocator.dart';

import '../models/bus.dart';
import '../providers/theme_provider.dart';
import '../services/bus_service.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../widgets/bus_marker.dart';
import '../widgets/bus_details_sheet.dart';
import '../data/sample_locations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final BusService _busService = BusService();
  final LocationService _locationService = LocationService();
  final PanelController _panelController = PanelController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  Bus? _selectedBus;
  LatLng? _userLocation;
  LatLng? _destinationLocation;
  bool _isFollowingUser = true;
  bool _isSearchExpanded = false;
  bool _showDestinationInput = false;
  List<LatLng>? _selectedRoute;
  bool _isLoadingRoute = false;

  // Demo sample locations.
  final List<Map<String, dynamic>> _sampleLocations = sampleLocations;

  // Default center: roughly the demo center.
  static const LatLng _defaultCenter = LatLng(
    34.88244789418636,
    -1.3179058311144984,
  );

  StreamSubscription<LatLng>? _locationSubscription;

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
      if (location != null && mounted) {
        setState(() => _userLocation = location);
        _mapController.move(location, 15);
      }
      _locationService.startLocationUpdates();
      _locationSubscription = _locationService.locationStream.listen((
        location,
      ) {
        if (mounted) {
          setState(() => _userLocation = location);
          if (_isFollowingUser) {
            _mapController.move(location, _mapController.camera.zoom);
          }
        }
      });
    }
  }

  Future<void> _handleLocateMe() async {
    // Re-request permission when "locate me" is pressed.
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      // Show a dialog to guide the user to app settings.
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Location Permission'),
                content: const Text(
                  'Location permission is disabled. Please enable it in your device settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Geolocator.openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
        );
      }
      return;
    }
    // If permission granted, update location.
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _userLocation = location;
        _isFollowingUser = true;
      });
      _mapController.move(location, 15);
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    if (!mounted) return;
    setState(() => _isLoadingRoute = true);
    try {
      final route = await RouteService.getRoute(start, end);
      if (mounted) {
        setState(() {
          _selectedRoute = route ?? [];
          _isLoadingRoute = false;
        });
      }
    } catch (e) {
      debugPrint('Error getting route: $e');
      if (mounted) {
        setState(() {
          _selectedRoute = [];
          _isLoadingRoute = false;
        });
      }
    }
  }

  void _onBusSelected(Bus bus) {
    setState(() => _selectedBus = bus);
    _panelController.open();
    _mapController.move(bus.position, 15);
    _isFollowingUser = false;
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

  // Filter locations by any field starting with "name"
  List<Map<String, dynamic>> _filterLocations(String query) {
    return _sampleLocations.where((location) {
      return location.entries.any((entry) {
        if (entry.key == 'name' || entry.key.startsWith('name_')) {
          return (entry.value as String).toLowerCase().contains(query);
        }
        return false;
      });
    }).toList();
  }

  List<Widget> _buildSearchResults() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return [];
    final filtered = _filterLocations(query);
    return filtered.map((location) {
      return ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(
          location['name'],
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: () {
          _setDestination(
            LatLng(location['lat'], location['lng']),
            location['name'],
          );
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _busService.dispose();
    _locationService.dispose();
    _locationSubscription?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Precompute search results for performance.
    final searchResults =
        _isSearchExpanded ? _buildSearchResults() : <Widget>[];

    return Scaffold(
      body: Stack(
        children: [
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 0,
            maxHeight: 300,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            panel:
                _selectedBus != null
                    ? BusDetailsSheet(bus: _selectedBus!)
                    : const SizedBox.shrink(),
            body: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation ?? _defaultCenter,
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
                // Route polyline with color based on theme
                if (_selectedRoute != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _selectedRoute!,
                        color:
                            themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.blue,
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
                        child: BusMarker(
                          heading: bus.heading,
                          isSelected: bus.id == _selectedBus?.id,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showDestinationInput)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    decoration: BoxDecoration(
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[800]
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(26, 0, 0, 0),
                          blurRadius: 8,
                          offset: Offset(0, 2),
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
                              style: Theme.of(context).textTheme.bodyLarge,
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: _isSearchExpanded ? 0 : 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        themeProvider.isDarkMode
                            ? Colors.grey[800]
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(26, 0, 0, 0),
                        blurRadius: 8,
                        offset: Offset(0, 2),
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
                          hintStyle: Theme.of(context).textTheme.bodyLarge,
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
                        ...searchResults,
                        if (_searchController.text.isNotEmpty &&
                            searchResults.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No locations found. Try a different search.',
                            ),
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
          // Locate Me Button: now calls _handleLocateMe()
          FloatingActionButton(
            heroTag: 'location',
            onPressed: _handleLocateMe,
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
