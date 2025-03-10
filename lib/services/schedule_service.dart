import '../models/schedule.dart';

class ScheduleService {
  // Singleton pattern
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  // Get all schedules
  List<BusSchedule> getAllSchedules() {
    return _sampleSchedules;
  }

  // Get schedule by route ID
  BusSchedule? getScheduleByRouteId(String routeId) {
    try {
      return _sampleSchedules.firstWhere((schedule) => schedule.routeId == routeId);
    } catch (e) {
      return null;
    }
  }

  // Get schedules by day of operation
  List<BusSchedule> getSchedulesByDay(String day) {
    return _sampleSchedules.where((schedule) => 
      schedule.daysOfOperation.toLowerCase().contains(day.toLowerCase())).toList();
  }

  // Sample schedules data
  final List<BusSchedule> _sampleSchedules = [
    BusSchedule(
      routeId: 'R1',
      routeName: 'Central Station - City Mall',
      busNumber: 'BUS1',
      daysOfOperation: 'Weekdays',
      stops: [
        ScheduleStop(
          stopId: 'S1',
          stopName: 'Central Station',
          arrivalTime: '06:00',
          departureTime: '06:05',
        ),
        ScheduleStop(
          stopId: 'S2',
          stopName: 'Downtown',
          arrivalTime: '06:15',
          departureTime: '06:17',
        ),
        ScheduleStop(
          stopId: 'S3',
          stopName: 'City Mall',
          arrivalTime: '06:30',
          departureTime: '06:35',
        ),
      ],
    ),
    BusSchedule(
      routeId: 'R2',
      routeName: 'Central Station - University Campus',
      busNumber: 'BUS2',
      daysOfOperation: 'Daily',
      stops: [
        ScheduleStop(
          stopId: 'S1',
          stopName: 'Central Station',
          arrivalTime: '07:00',
          departureTime: '07:05',
        ),
        ScheduleStop(
          stopId: 'S4',
          stopName: 'Library',
          arrivalTime: '07:20',
          departureTime: '07:22',
        ),
        ScheduleStop(
          stopId: 'S5',
          stopName: 'University Campus',
          arrivalTime: '07:35',
          departureTime: '07:40',
        ),
      ],
    ),
    BusSchedule(
      routeId: 'R3',
      routeName: 'Central Station - Tech Park',
      busNumber: 'BUS3',
      daysOfOperation: 'Weekdays',
      stops: [
        ScheduleStop(
          stopId: 'S1',
          stopName: 'Central Station',
          arrivalTime: '08:00',
          departureTime: '08:05',
        ),
        ScheduleStop(
          stopId: 'S6',
          stopName: 'Business District',
          arrivalTime: '08:25',
          departureTime: '08:27',
        ),
        ScheduleStop(
          stopId: 'S7',
          stopName: 'Tech Park',
          arrivalTime: '08:45',
          departureTime: '08:50',
        ),
      ],
    ),
    BusSchedule(
      routeId: 'R4',
      routeName: 'Central Station - Hospital',
      busNumber: 'BUS4',
      daysOfOperation: 'Daily',
      stops: [
        ScheduleStop(
          stopId: 'S1',
          stopName: 'Central Station',
          arrivalTime: '09:00',
          departureTime: '09:05',
        ),
        ScheduleStop(
          stopId: 'S8',
          stopName: 'Market Square',
          arrivalTime: '09:20',
          departureTime: '09:22',
        ),
        ScheduleStop(
          stopId: 'S9',
          stopName: 'Hospital',
          arrivalTime: '09:35',
          departureTime: '09:40',
        ),
      ],
    ),
    BusSchedule(
      routeId: 'R5',
      routeName: 'City Mall - University Campus',
      busNumber: 'BUS5',
      daysOfOperation: 'Weekends',
      stops: [
        ScheduleStop(
          stopId: 'S3',
          stopName: 'City Mall',
          arrivalTime: '10:00',
          departureTime: '10:05',
        ),
        ScheduleStop(
          stopId: 'S1',
          stopName: 'Central Station',
          arrivalTime: '10:20',
          departureTime: '10:25',
        ),
        ScheduleStop(
          stopId: 'S5',
          stopName: 'University Campus',
          arrivalTime: '10:40',
          departureTime: '10:45',
        ),
      ],
    ),
  ];
} 