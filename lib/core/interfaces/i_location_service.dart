import 'package:skibidi/models/location_point.dart';

/// Interface for location tracking service - allows swapping GPS providers
/// Current implementation: FlutterBgLocationService (flutter_background_geolocation)
/// Alternative implementations: GeolocatorLocationService, NativeLocationService, etc.
abstract class ILocationService {
  /// Stream of location updates
  Stream<LocationPoint> get locationStream;

  /// Start tracking user location
  Future<void> startTracking();

  /// Stop tracking completely
  Future<void> stopTracking();

  /// Pause tracking temporarily
  Future<void> pauseTracking();

  /// Resume tracking after pause
  Future<void> resumeTracking();

  /// Request necessary permissions for location tracking
  Future<bool> requestPermissions();

  /// Get current location once (without streaming)
  Future<LocationPoint?> getCurrentLocation();

  /// Check if currently tracking
  bool get isTracking;
}
