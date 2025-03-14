import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../services/route_service.dart';
import '../../data/sample_locations.dart';

class RouteDetailsScreen extends StatefulWidget {
  final String routeId;
  const RouteDetailsScreen({super.key, required this.routeId});

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  BusSchedule? _schedule;
  List<LatLng>? _routePoints;
  bool _isLoadingRoute = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() {
    _schedule = _scheduleService.getScheduleByRouteId(widget.routeId);
    if (_schedule != null) {
      _loadRoutePoints();
    }
    // Only call setState if the widget is mounted.
    if (mounted) setState(() {});
  }

  Future<void> _loadRoutePoints() async {
    if (_schedule == null || _schedule!.stops.length < 2) return;

    setState(() => _isLoadingRoute = true);
    try {
      final firstStop = getStopCoordinates(_schedule!.stops.first.stopName);
      final lastStop = getStopCoordinates(_schedule!.stops.last.stopName);
      if (firstStop != null && lastStop != null) {
        final route = await RouteService.getSimulatedRoute(firstStop, lastStop);
        if (mounted) {
          _routePoints = route;
          _isLoadingRoute = false;
          _centerMapOnRoute();
          setState(() {}); // Update the UI after loading route points
        }
      }
    } catch (e) {
      debugPrint('Error loading route: $e');
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  void _centerMapOnRoute() {
    if (_routePoints == null || _routePoints!.isEmpty) return;
    double sumLat = 0;
    double sumLng = 0;
    for (var point in _routePoints!) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    final center = LatLng(
      sumLat / _routePoints!.length,
      sumLng / _routePoints!.length,
    );
    _mapController.move(center, 13);
  }

  @override
  Widget build(BuildContext context) {
    if (_schedule == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Route Details')),
        body: const Center(child: Text('Schedule not found')),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          // Map Section
          SizedBox(
            height: screenHeight * 0.4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        getStopCoordinates(_schedule!.stops.first.stopName) ??
                        const LatLng(12.9716, 77.5946),
                    initialZoom: 13,
                    onTap: (_, __) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bus_tracking_app',
                    ),
                    if (_routePoints != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints!,
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers:
                          _schedule!.stops.map((stop) {
                            final coordinates = getStopCoordinates(
                              stop.stopName,
                            );
                            if (coordinates == null) {
                              return const Marker(
                                point: LatLng(0, 0),
                                child: SizedBox(),
                              );
                            }
                            return Marker(
                              point: coordinates,
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
                // Back Button
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                if (_isLoadingRoute)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          // Route Information and Timeline
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _schedule!.routeName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _schedule!.busNumber,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Operates on: ${_schedule!.daysOfOperation}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total journey time: ${_schedule!.formattedJourneyTime}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stops',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_schedule!.stops.length, (index) {
                    final stop = _schedule!.stops[index];
                    final isFirst = index == 0;
                    final isLast = index == _schedule!.stops.length - 1;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Column(
                            children: [
                              if (!isFirst)
                                Container(
                                  width: 2,
                                  height: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color:
                                      isFirst || isLast
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.stopName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Arrival: ${stop.arrivalTime}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.departure_board,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Departure: ${stop.departureTime}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/map/compare'),
        icon: const Icon(Icons.compare_arrows),
        label: const Text('Compare Routes'),
      ),
    );
  }
}
