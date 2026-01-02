import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:skibidi/core/interfaces/i_location_service.dart';
import 'package:skibidi/models/location_point.dart';

/// Implementation of location service using flutter_background_geolocation
class FlutterBgLocationService implements ILocationService {
  final _locationController = StreamController<LocationPoint>.broadcast();
  bool _isTracking = false;

  @override
  Stream<LocationPoint> get locationStream => _locationController.stream;

  @override
  bool get isTracking => _isTracking;

  @override
  Future<void> startTracking() async {
    if (_isTracking) return;

    // Configure background geolocation
    await bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0, // meters
        stopTimeout: 5, // minutes
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        stopOnTerminate: false,
        startOnBoot: false,
        enableHeadless: true,
        heartbeatInterval: 60,
      ),
    );

    // Listen to location updates
    bg.BackgroundGeolocation.onLocation(_onLocation);

    // Start tracking
    await bg.BackgroundGeolocation.start();
    _isTracking = true;
  }

  @override
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    await bg.BackgroundGeolocation.stop();
    _isTracking = false;
  }

  @override
  Future<void> pauseTracking() async {
    await bg.BackgroundGeolocation.changePace(false);
  }

  @override
  Future<void> resumeTracking() async {
    await bg.BackgroundGeolocation.changePace(true);
  }

  @override
  Future<bool> requestPermissions() async {
    final status = await bg.BackgroundGeolocation.requestPermission();
    return status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS ||
        status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_WHEN_IN_USE;
  }

  @override
  Future<LocationPoint?> getCurrentLocation() async {
    try {
      final location = await bg.BackgroundGeolocation.getCurrentPosition(
        timeout: 30,
        maximumAge: 0,
        desiredAccuracy: 10,
      );
      return _convertToLocationPoint(location);
    } catch (e) {
      return null;
    }
  }

  void _onLocation(bg.Location location) {
    final point = _convertToLocationPoint(location);
    _locationController.add(point);
  }

  LocationPoint _convertToLocationPoint(bg.Location location) {
    return LocationPoint(
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      altitude: location.coords.altitude,
      speed: location.coords.speed * 3.6, // m/s to km/h
      heading: location.coords.heading,
      accuracy: location.coords.accuracy,
      timestamp: DateTime.parse(location.timestamp),
    );
  }

  void dispose() {
    _locationController.close();
  }
}
