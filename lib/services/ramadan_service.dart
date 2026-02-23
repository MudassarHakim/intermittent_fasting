import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class RamadanTimes {
  final DateTime suhoorEnd; // Fajr - when to stop eating
  final DateTime iftarStart; // Maghrib - when to break fast
  final Duration fastingDuration;

  RamadanTimes({
    required this.suhoorEnd,
    required this.iftarStart,
    required this.fastingDuration,
  });
}

class RamadanService {
  RamadanService._();

  static Position? _cachedPosition;
  static DateTime? _cacheTime;

  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    if (_cachedPosition != null && _cacheTime != null) {
      final diff = DateTime.now().difference(_cacheTime!);
      if (diff.inMinutes < 30) return _cachedPosition;
    }

    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) return null;

      _cachedPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _cacheTime = DateTime.now();
      return _cachedPosition;
    } catch (e) {
      return null;
    }
  }

  static Future<RamadanTimes?> getTodayTimes() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    return calculateTimes(
      latitude: position.latitude,
      longitude: position.longitude,
      date: DateTime.now(),
    );
  }

  static RamadanTimes calculateTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(date),
      params,
    );

    final fajr = prayerTimes.fajr;
    final maghrib = prayerTimes.maghrib;
    final duration = maghrib.difference(fajr);

    return RamadanTimes(
      suhoorEnd: fajr,
      iftarStart: maghrib,
      fastingDuration: duration,
    );
  }

  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
