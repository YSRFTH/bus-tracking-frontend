import 'package:latlong2/latlong.dart';
import '../models/schedule.dart';

/// Demo locations used in the map screen.
final List<Map<String, dynamic>> sampleLocations = [
  {
    'name': 'Lala Setti',
    'name_ar': 'لالة ستي',
    'name_fr': 'Lalla Setti',
    'lat': 34.86342029661403,
    'lng': -1.3166552463942125,
  },
  {
    'name': 'Mechouar Castle',
    'name_ar': 'قلعة المشور',
    'name_fr': 'Château Mechouar',
    'lat': 34.88215803,
    'lng': -1.30850108,
  },
  {
    'name': 'Culture Castle of Tlemcen',
    'name_ar': 'قلعة الثقافة تلمسان',
    'name_fr': 'Château de la Culture de Tlemcen',
    'lat': 34.87974555766004,
    'lng': -1.3349350750467224,
  },
  {
    'name': 'Mansourah Castle',
    'name_ar': 'قلعة المنصورة',
    'name_fr': 'Château Mansourah',
    'lat': 34.871301317244274,
    'lng': -1.3393463098908738,
  },
  {
    'name': 'Cave of Bouhanaq',
    'name_ar': 'كهف بوحناق',
    'name_fr': 'Grotte de Bouhanaq',
    'lat': 34.8805616029737,
    'lng': -1.3719292929259848,
  },
  {
    'name': 'Harkoun Park',
    'name_ar': 'حديقة هركون',
    'name_fr': 'Parc Harkoun',
    'lat': 34.8776236598376,
    'lng': -1.3028773908088402,
  },
];

/// Schedule stop locations used in your bus schedules.
final List<Map<String, dynamic>> scheduleStopLocations = [
  {'name': 'Central Station', 'lat': 12.9716, 'lng': 77.5946},
  {'name': 'Downtown', 'lat': 12.9756, 'lng': 77.5986},
  {'name': 'City Mall', 'lat': 12.9816, 'lng': 77.6046},
  {'name': 'Library', 'lat': 12.9656, 'lng': 77.5886},
  {'name': 'University Campus', 'lat': 12.9616, 'lng': 77.5846},
  {'name': 'Business District', 'lat': 12.9836, 'lng': 77.6066},
  {'name': 'Tech Park', 'lat': 12.9916, 'lng': 77.6146},
  {'name': 'Market Square', 'lat': 12.9556, 'lng': 77.5786},
  {'name': 'Hospital', 'lat': 12.9516, 'lng': 77.5746},
];

final List<BusSchedule> sampleSchedules = [
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

/// Combined map of stop coordinates from both data sets.
/// This serves as the single source of truth for stop coordinates.
final Map<String, LatLng> stopCoordinates = {
  for (var location in sampleLocations)
    location['name'] as String: LatLng(
      location['lat'] as double,
      location['lng'] as double,
    ),
  for (var location in scheduleStopLocations)
    location['name'] as String: LatLng(
      location['lat'] as double,
      location['lng'] as double,
    ),
};

/// Returns the coordinates for a given stop name.
LatLng? getStopCoordinates(String stopName) {
  return stopCoordinates[stopName];
}
