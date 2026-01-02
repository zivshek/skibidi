import 'package:flutter/widgets.dart';
import 'package:skibidi/models/trail.dart';
import 'package:skibidi/models/location_point.dart';

/// Configuration for map widget
class MapConfig {
  final double initialZoom;
  final LocationPoint? initialCenter;
  final bool showUserLocation;
  final bool followUser;

  const MapConfig({
    this.initialZoom = 14.0,
    this.initialCenter,
    this.showUserLocation = true,
    this.followUser = false,
  });
}

/// Interface for map provider - allows swapping map implementations
/// Current implementation: MapboxMapProvider
/// Alternative implementations: GoogleMapsProvider, OpenStreetMapProvider, etc.
abstract class IMapProvider {
  /// Build the map widget
  Widget buildMapWidget({required MapConfig config});

  /// Add trail overlays to the map (color-coded by difficulty)
  Future<void> addTrailOverlay(List<Trail> trails);

  /// Update user's current location on map
  Future<void> updateUserLocation(LocationPoint location);

  /// Highlight a specific trail (e.g., when user is on it)
  Future<void> highlightTrail(String trailId);

  /// Center map on a specific location
  Future<void> centerOnLocation(LocationPoint location, {double? zoom});

  /// Fit map to show all trails
  Future<void> fitToTrails(List<Trail> trails);
}
