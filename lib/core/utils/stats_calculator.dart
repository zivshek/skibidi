import 'package:skibidi/models/trail_visit.dart';
import 'package:skibidi/models/session_statistics.dart';
import 'package:skibidi/models/trail.dart';

/// Utility class for calculating session statistics
class StatsCalculator {
  /// Calculate complete session statistics from trail visits
  static SessionStatistics calculateSessionStats(
    List<TrailVisit> visits,
    List<Trail> allTrails,
  ) {
    if (visits.isEmpty) {
      return SessionStatistics.empty();
    }

    double totalVertical = 0.0;
    double totalDistance = 0.0;
    double maxSpeed = 0.0;
    Duration timeSkiing = Duration.zero;
    Duration timeOnLift = Duration.zero;
    int greenTrails = 0;
    int blueTrails = 0;
    int blackTrails = 0;
    int doubleBlackTrails = 0;
    final Map<String, int> trailCounts = {};

    for (final visit in visits) {
      // Accumulate distance
      totalDistance += visit.distance;

      // Track max speed
      if (visit.maxSpeed > maxSpeed) {
        maxSpeed = visit.maxSpeed;
      }

      // Accumulate time
      if (visit.isLift) {
        timeOnLift += visit.duration;
      } else {
        timeSkiing += visit.duration;
        // Only count vertical descent when skiing down
        totalVertical += visit.verticalChange.abs();
      }

      // Count trails by difficulty
      if (!visit.isLift) {
        final trail = allTrails.firstWhere(
          (t) => t.id == visit.trailId,
          orElse: () => Trail(
            id: visit.trailId,
            name: 'Unknown',
            difficulty: TrailDifficulty.blue,
            resortId: '',
            coordinates: [],
          ),
        );

        switch (trail.difficulty) {
          case TrailDifficulty.green:
            greenTrails++;
            break;
          case TrailDifficulty.blue:
            blueTrails++;
            break;
          case TrailDifficulty.black:
            blackTrails++;
            break;
          case TrailDifficulty.doubleBlack:
            doubleBlackTrails++;
            break;
        }

        // Count individual trail visits
        trailCounts[visit.trailId] = (trailCounts[visit.trailId] ?? 0) + 1;
      }
    }

    // Calculate average speed
    final totalHours = (timeSkiing.inSeconds + timeOnLift.inSeconds) / 3600.0;
    final avgSpeed = totalHours > 0
        ? (totalDistance / 1000.0) / totalHours
        : 0.0;

    return SessionStatistics(
      totalVertical: totalVertical,
      totalDistance: totalDistance,
      maxSpeed: maxSpeed,
      avgSpeed: avgSpeed,
      timeSkiing: timeSkiing,
      timeOnLift: timeOnLift,
      greenTrails: greenTrails,
      blueTrails: blueTrails,
      blackTrails: blackTrails,
      doubleBlackTrails: doubleBlackTrails,
      trailCounts: trailCounts,
    );
  }

  /// Format distance for display
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Format speed for display
  static String formatSpeed(double kmh) {
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  /// Format vertical for display
  static String formatVertical(double meters) {
    return '${meters.toStringAsFixed(0)} m';
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
