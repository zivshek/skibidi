import 'dart:math' as math;
import 'package:skibidi/models/location_point.dart';

/// Utility functions for geographic calculations
class GeoUtils {
  /// Earth's radius in meters
  static const double earthRadius = 6371000.0;

  /// Calculate distance between two points using Haversine formula (in meters)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Check if a point is inside a polygon (ray-casting algorithm)
  /// polygon: List of [lng, lat] coordinates
  static bool isPointInPolygon(
    double lat,
    double lon,
    List<List<double>> polygon,
  ) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i][0]; // longitude
      final yi = polygon[i][1]; // latitude
      final xj = polygon[j][0];
      final yj = polygon[j][1];

      final intersect =
          ((yi > lat) != (yj > lat)) &&
          (lon < (xj - xi) * (lat - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// Calculate minimum distance from a point to a line (trail)
  /// Returns distance in meters
  static double distanceToLine(
    double lat,
    double lon,
    List<List<double>> lineCoordinates,
  ) {
    double minDistance = double.infinity;

    for (int i = 0; i < lineCoordinates.length - 1; i++) {
      final p1Lat = lineCoordinates[i][1];
      final p1Lon = lineCoordinates[i][0];
      final p2Lat = lineCoordinates[i + 1][1];
      final p2Lon = lineCoordinates[i + 1][0];

      final distance = _distanceToSegment(lat, lon, p1Lat, p1Lon, p2Lat, p2Lon);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance;
  }

  /// Calculate perpendicular distance from point to line segment
  static double _distanceToSegment(
    double lat,
    double lon,
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final x = lat;
    final y = lon;
    final x1 = lat1;
    final y1 = lon1;
    final x2 = lat2;
    final y2 = lon2;

    final A = x - x1;
    final B = y - y1;
    final C = x2 - x1;
    final D = y2 - y1;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    var param = -1.0;

    if (lenSq != 0) {
      param = dot / lenSq;
    }

    double xx, yy;

    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    return calculateDistance(x, y, xx, yy);
  }

  /// Calculate total distance along a path
  static double calculatePathDistance(List<LocationPoint> path) {
    if (path.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < path.length - 1; i++) {
      totalDistance += calculateDistance(
        path[i].latitude,
        path[i].longitude,
        path[i + 1].latitude,
        path[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  /// Calculate total elevation change along a path
  static double calculateElevationChange(List<LocationPoint> path) {
    if (path.isEmpty) return 0.0;

    final altitudes = path
        .map((p) => p.altitude)
        .where((a) => a != null)
        .cast<double>()
        .toList();

    if (altitudes.length < 2) return 0.0;

    return altitudes.last - altitudes.first;
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
}
