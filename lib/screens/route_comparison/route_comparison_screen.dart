import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../services/route_service.dart';
import '../../data/sample_locations.dart';

class RouteComparisonScreen extends StatefulWidget {
  const RouteComparisonScreen({super.key});

  @override
  State<RouteComparisonScreen> createState() => _RouteComparisonScreenState();
}

class _RouteComparisonScreenState extends State<RouteComparisonScreen> {
  final _scheduleService = ScheduleService();
  final _mapController = MapController();
  final List<BusSchedule> _allSchedules = [];
  final List<BusSchedule> _selectedSchedules = [];
  final Map<String, List<LatLng>> _routePoints = {};
  final Map<String, Color> _routeColors = {};
  bool _isLoadingRoutes = false;

  // Predefined colors for routes
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    setState(() {
      _allSchedules.clear();
      _allSchedules.addAll(_scheduleService.getAllSchedules());
    });
  }

  void _toggleScheduleSelection(BusSchedule schedule) {
    setState(() {
      if (_selectedSchedules.contains(schedule)) {
        _selectedSchedules.remove(schedule);
        _routePoints.remove(schedule.routeId);
        _routeColors.remove(schedule.routeId);
      } else {
        if (_selectedSchedules.length < 3) {
          _selectedSchedules.add(schedule);
          _loadRoutePoints(schedule);
        } else {
          // Show snackbar if more than 3 routes are selected
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can compare up to 3 routes at a time'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _loadRoutePoints(BusSchedule schedule) async {
    if (schedule.stops.length < 2) return;

    setState(() => _isLoadingRoutes = true);

    try {
      // Get coordinates for first and last stop
      final firstStop = _getStopCoordinates(schedule.stops.first.stopName);
      final lastStop = _getStopCoordinates(schedule.stops.last.stopName);

      if (firstStop != null && lastStop != null) {
        // For demo purposes, use simulated route
        final route = await RouteService.getSimulatedRoute(firstStop, lastStop);

        // Assign a color to this route
        final color = _colors[_selectedSchedules.length - 1 % _colors.length];

        setState(() {
          _routePoints[schedule.routeId] = route;
          _routeColors[schedule.routeId] = color;
          _isLoadingRoutes = false;
        });

        // Center map on routes
        _centerMapOnRoutes();
      }
    } catch (e) {
      print('Error loading route: $e');
      setState(() => _isLoadingRoutes = false);
    }
  }

  void _centerMapOnRoutes() {
    if (_routePoints.isEmpty) return;

    // Calculate the center of all routes
    double sumLat = 0;
    double sumLng = 0;
    int totalPoints = 0;

    for (var points in _routePoints.values) {
      for (var point in points) {
        sumLat += point.latitude;
        sumLng += point.longitude;
        totalPoints++;
      }
    }

    if (totalPoints > 0) {
      final center = LatLng(sumLat / totalPoints, sumLng / totalPoints);
      _mapController.move(center, 13);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Routes'),
        actions: [
          if (_selectedSchedules.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _selectedSchedules.clear();
                  _routePoints.clear();
                  _routeColors.clear();
                });
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: Column(
        children: [
          // Map section
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(12.9716, 77.5946),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bus_tracking_app',
                    ),
                    // Draw route polylines
                    PolylineLayer(
                      polylines:
                          _routePoints.entries.map((entry) {
                            return Polyline(
                              points: entry.value,
                              color: _routeColors[entry.key] ?? Colors.blue,
                              strokeWidth: 4.0,
                            );
                          }).toList(),
                    ),
                    // Draw stop markers for selected routes
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ),
                // Loading indicator
                if (_isLoadingRoutes)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),

          // Comparison section
          if (_selectedSchedules.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comparison',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildComparisonTable(),
                ],
              ),
            ),
          ],

          // Available routes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allSchedules.length,
              itemBuilder: (context, index) {
                final schedule = _allSchedules[index];
                final isSelected = _selectedSchedules.contains(schedule);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side:
                        isSelected
                            ? BorderSide(
                              color:
                                  _routeColors[schedule.routeId] ??
                                  Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                            : BorderSide.none,
                  ),
                  child: ListTile(
                    title: Text(schedule.routeName),
                    subtitle: Text(
                      '${schedule.formattedJourneyTime} • ${schedule.daysOfOperation}',
                    ),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle,
                              color:
                                  _routeColors[schedule.routeId] ??
                                  Theme.of(context).colorScheme.primary,
                            )
                            : const Icon(Icons.add_circle_outline),
                    onTap: () => _toggleScheduleSelection(schedule),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LatLng? _getStopCoordinates(String stopName) {
    return getStopCoordinates(stopName);
  }

  Widget _buildComparisonTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Route',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(_selectedSchedules.length, (index) {
              final schedule = _selectedSchedules[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  schedule.busNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _routeColors[schedule.routeId],
                  ),
                ),
              );
            }),
            if (_selectedSchedules.length < 3)
              ...List.generate(
                3 - _selectedSchedules.length,
                (_) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('-'),
                ),
              ),
          ],
        ),
        // Journey time row
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Journey Time'),
            ),
            ...List.generate(_selectedSchedules.length, (index) {
              final schedule = _selectedSchedules[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(schedule.formattedJourneyTime),
              );
            }),
            if (_selectedSchedules.length < 3)
              ...List.generate(
                3 - _selectedSchedules.length,
                (_) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('-'),
                ),
              ),
          ],
        ),
        // Stops row
        TableRow(
          children: [
            const Padding(padding: EdgeInsets.all(8.0), child: Text('Stops')),
            ...List.generate(_selectedSchedules.length, (index) {
              final schedule = _selectedSchedules[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${schedule.stopCount}'),
              );
            }),
            if (_selectedSchedules.length < 3)
              ...List.generate(
                3 - _selectedSchedules.length,
                (_) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('-'),
                ),
              ),
          ],
        ),
        // First departure row
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('First Departure'),
            ),
            ...List.generate(_selectedSchedules.length, (index) {
              final schedule = _selectedSchedules[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(schedule.firstDeparture),
              );
            }),
            if (_selectedSchedules.length < 3)
              ...List.generate(
                3 - _selectedSchedules.length,
                (_) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('-'),
                ),
              ),
          ],
        ),
        // Last arrival row
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Last Arrival'),
            ),
            ...List.generate(_selectedSchedules.length, (index) {
              final schedule = _selectedSchedules[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(schedule.lastArrival),
              );
            }),
            if (_selectedSchedules.length < 3)
              ...List.generate(
                3 - _selectedSchedules.length,
                (_) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('-'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    for (var schedule in _selectedSchedules) {
      for (var stop in [schedule.stops.first, schedule.stops.last]) {
        final coordinates = _getStopCoordinates(stop.stopName);
        if (coordinates != null) {
          markers.add(
            Marker(
              point: coordinates,
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: _routeColors[schedule.routeId] ?? Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          );
        }
      }
    }
    return markers;
  }
}
