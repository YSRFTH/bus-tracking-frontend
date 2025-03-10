class BusSchedule {
  final String routeId;
  final String routeName;
  final String busNumber;
  final List<ScheduleStop> stops;
  final String daysOfOperation; // e.g., "Weekdays", "Weekends", "Daily"
  final bool isActive;

  BusSchedule({
    required this.routeId,
    required this.routeName,
    required this.busNumber,
    required this.stops,
    required this.daysOfOperation,
    this.isActive = true,
  });

  // First departure time
  String get firstDeparture => stops.first.departureTime;

  // Last arrival time
  String get lastArrival => stops.last.arrivalTime;

  // Total journey time in minutes
  int get totalJourneyTime {
    final firstTime = _timeToMinutes(stops.first.departureTime);
    final lastTime = _timeToMinutes(stops.last.arrivalTime);
    return lastTime - firstTime;
  }

  // Convert time string (HH:MM) to minutes since midnight
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Format journey time as a string (e.g., "1h 30m")
  String get formattedJourneyTime {
    final minutes = totalJourneyTime;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  // Number of stops
  int get stopCount => stops.length;
}

class ScheduleStop {
  final String stopId;
  final String stopName;
  final String arrivalTime;
  final String departureTime;

  ScheduleStop({
    required this.stopId,
    required this.stopName,
    required this.arrivalTime,
    required this.departureTime,
  });
} 