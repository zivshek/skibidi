import 'dart:async';
import 'dart:math';
import 'package:skibidi/core/interfaces/i_location_service.dart';
import 'package:skibidi/models/location_point.dart';

/// Mock location service that simulates GPS movement along a trail
/// Useful for testing without actual GPS hardware
class MockLocationService implements ILocationService {
  final _locationController = StreamController<LocationPoint>.broadcast();
  bool _isTracking = false;
  Timer? _timer;

  // Simulate movement along Mont Tremblant trails
  int _pointIndex = 0;
  final List<Map<String, dynamic>> _simulatedRoute = [
    // Starting point (base of gondola)
    {'lat': 46.2065, 'lng': -74.5905, 'alt': 265, 'speed': 0},

    // Riding gondola up
    {'lat': 46.207, 'lng': -74.591, 'alt': 365, 'speed': 18}, // on lift
    {'lat': 46.2075, 'lng': -74.5915, 'alt': 465, 'speed': 18},
    {'lat': 46.208, 'lng': -74.592, 'alt': 565, 'speed': 18},
    {'lat': 46.2085, 'lng': -74.5925, 'alt': 665, 'speed': 18},
    {'lat': 46.209, 'lng': -74.593, 'alt': 765, 'speed': 18},
    {'lat': 46.2095, 'lng': -74.5935, 'alt': 875, 'speed': 15}, // top
    // Pause at top
    {'lat': 46.2095, 'lng': -74.5935, 'alt': 875, 'speed': 0},

    // Skiing down Nansen (blue run)
    {'lat': 46.209, 'lng': -74.593, 'alt': 800, 'speed': 35},
    {'lat': 46.2085, 'lng': -74.5925, 'alt': 720, 'speed': 42},
    {'lat': 46.208, 'lng': -74.592, 'alt': 640, 'speed': 38},
    {'lat': 46.2075, 'lng': -74.5915, 'alt': 560, 'speed': 45},
    {'lat': 46.207, 'lng': -74.591, 'alt': 480, 'speed': 40},
    {'lat': 46.2065, 'lng': -74.5905, 'alt': 400, 'speed': 35},
    {'lat': 46.206, 'lng': -74.590, 'alt': 320, 'speed': 30},
    {'lat': 46.2055, 'lng': -74.5895, 'alt': 265, 'speed': 15}, // bottom
    // Pause at bottom
    {'lat': 46.2055, 'lng': -74.5895, 'alt': 265, 'speed': 0},

    // Back on gondola
    {'lat': 46.206, 'lng': -74.590, 'alt': 365, 'speed': 17},
    {'lat': 46.2065, 'lng': -74.5905, 'alt': 465, 'speed': 17},
    {'lat': 46.207, 'lng': -74.591, 'alt': 565, 'speed': 17},
    {'lat': 46.2075, 'lng': -74.5915, 'alt': 665, 'speed': 18},
    {'lat': 46.208, 'lng': -74.592, 'alt': 765, 'speed': 18},
    {'lat': 46.2085, 'lng': -74.5925, 'alt': 875, 'speed': 16},

    // Skiing down Dynamite (black run) - faster
    {'lat': 46.208, 'lng': -74.5925, 'alt': 820, 'speed': 45},
    {'lat': 46.2075, 'lng': -74.592, 'alt': 740, 'speed': 52},
    {'lat': 46.207, 'lng': -74.5915, 'alt': 660, 'speed': 58},
    {'lat': 46.2065, 'lng': -74.591, 'alt': 580, 'speed': 55},
    {'lat': 46.206, 'lng': -74.5905, 'alt': 500, 'speed': 48},
    {'lat': 46.2055, 'lng': -74.590, 'alt': 420, 'speed': 45},
    {'lat': 46.205, 'lng': -74.5895, 'alt': 340, 'speed': 40},
    {'lat': 46.2045, 'lng': -74.589, 'alt': 265, 'speed': 20},
  ];

  @override
  Stream<LocationPoint> get locationStream => _locationController.stream;

  @override
  bool get isTracking => _isTracking;

  @override
  Future<void> startTracking() async {
    if (_isTracking) return;

    _isTracking = true;
    _pointIndex = 0;

    // Emit location points every 3 seconds to simulate realistic GPS updates
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pointIndex < _simulatedRoute.length) {
        final point = _simulatedRoute[_pointIndex];

        // Add some random variation to make it more realistic
        final random = Random();
        final latVariation = (random.nextDouble() - 0.5) * 0.0001;
        final lngVariation = (random.nextDouble() - 0.5) * 0.0001;
        final speedVariation = (random.nextDouble() - 0.5) * 2;

        final locationPoint = LocationPoint(
          latitude: point['lat'] + latVariation,
          longitude: point['lng'] + lngVariation,
          altitude: point['alt'].toDouble(),
          speed: (point['speed'] + speedVariation).clamp(0, 100),
          heading: _calculateHeading(_pointIndex),
          accuracy: 5.0 + random.nextDouble() * 5, // 5-10m accuracy
          timestamp: DateTime.now(),
        );

        _locationController.add(locationPoint);
        _pointIndex++;
      } else {
        // Loop back to start for continuous testing
        _pointIndex = 0;
      }
    });
  }

  @override
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _pointIndex = 0;
  }

  @override
  Future<void> pauseTracking() async {
    _timer?.cancel();
  }

  @override
  Future<void> resumeTracking() async {
    if (!_isTracking) return;
    // Restart timer from current position
    await startTracking();
  }

  @override
  Future<bool> requestPermissions() async {
    // Mock always grants permission
    return true;
  }

  @override
  Future<LocationPoint?> getCurrentLocation() async {
    if (_pointIndex < _simulatedRoute.length) {
      final point = _simulatedRoute[_pointIndex];
      return LocationPoint(
        latitude: point['lat'],
        longitude: point['lng'],
        altitude: point['alt'].toDouble(),
        speed: point['speed'].toDouble(),
        heading: 0,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );
    }
    return null;
  }

  double _calculateHeading(int index) {
    if (index == 0 || index >= _simulatedRoute.length - 1) return 0;

    final current = _simulatedRoute[index];
    final next = _simulatedRoute[index + 1];

    final dLat = next['lat'] - current['lat'];
    final dLng = next['lng'] - current['lng'];

    return atan2(dLng, dLat) * 180 / pi;
  }

  void dispose() {
    _timer?.cancel();
    _locationController.close();
  }
}
