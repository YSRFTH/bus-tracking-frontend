import '../../data/sample_locations.dart'; // Import unified stops data
import '../models/schedule.dart';

class ScheduleService {
  // Singleton pattern
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  // Get all schedules
  //Adjusted to fetch from sample_locations.
  List<BusSchedule> getAllSchedules() {
    return sampleSchedules;
  }

  // Get schedule by route ID
  BusSchedule? getScheduleByRouteId(String routeId) {
    try {
      return sampleSchedules.firstWhere(
        (schedule) => schedule.routeId == routeId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get schedules by day of operation
  List<BusSchedule> getSchedulesByDay(String day) {
    return sampleSchedules
        .where(
          (schedule) => schedule.daysOfOperation.toLowerCase().contains(
            day.toLowerCase(),
          ),
        )
        .toList();
  }
}
  // Sample schedules data using unified stop names from sample_locations.dart.
  // The stop names must match those defined in your centralized data.
