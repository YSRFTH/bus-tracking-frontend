import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  final _scheduleService = ScheduleService();
  late TabController _tabController;
  late List<BusSchedule> _schedules;
  String _selectedDay = 'All';
  bool _isSearching = false;
  final _searchController = TextEditingController();
  List<BusSchedule> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _schedules = _scheduleService.getAllSchedules();
    _filteredSchedules = _schedules;
    
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedDay = 'All';
            break;
          case 1:
            _selectedDay = 'Weekdays';
            break;
          case 2:
            _selectedDay = 'Weekends';
            break;
        }
        _filterSchedules();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterSchedules() {
    if (_selectedDay == 'All') {
      _filteredSchedules = _schedules;
    } else {
      _filteredSchedules = _scheduleService.getSchedulesByDay(_selectedDay);
    }
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      _filteredSchedules = _filteredSchedules.where((schedule) {
        return schedule.routeName.toLowerCase().contains(query) ||
               schedule.busNumber.toLowerCase().contains(query);
      }).toList();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filterSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('h:mm a');
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search routes or bus numbers',
                  border: InputBorder.none,
                ),
                onChanged: (_) => _onSearchChanged(),
                autofocus: true,
              )
            : const Text('Bus Schedules'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filterSchedules();
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Weekdays'),
            Tab(text: 'Weekends'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date and time header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(now),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Current time: ${timeFormat.format(now)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          
          // Schedules list
          Expanded(
            child: _filteredSchedules.isEmpty
                ? const Center(
                    child: Text('No schedules found'),
                  )
                : ListView.builder(
                    itemCount: _filteredSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _filteredSchedules[index];
                      return _ScheduleCard(
                        schedule: schedule,
                        onTap: () {
                          context.push('/map/route/${schedule.routeId}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final BusSchedule schedule;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.schedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route name and bus number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      schedule.routeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      schedule.busNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Journey details
              Row(
                children: [
                  // Start time and location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.firstDeparture,
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          schedule.stops.first.stopName,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  // Journey time
                  Column(
                    children: [
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      Text(
                        schedule.formattedJourneyTime,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  // End time and location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          schedule.lastArrival,
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          schedule.stops.last.stopName,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Bottom info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Days of operation
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        schedule.daysOfOperation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  // Number of stops
                  Row(
                    children: [
                      const Icon(Icons.place, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${schedule.stopCount} stops',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  // View details button
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('View Route'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 