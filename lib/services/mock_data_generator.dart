import 'package:uuid/uuid.dart';
import 'package:skibidi/models/ski_session.dart';
import 'package:skibidi/models/trail_visit.dart';
import 'package:skibidi/models/session_statistics.dart';
import 'package:skibidi/models/location_point.dart';

/// Helper class to generate mock session data for testing
class MockDataGenerator {
  static const _uuid = Uuid();

  /// Generate a complete mock session with realistic trail visits
  static SkiSession generateMockSession({
    required String resortId,
    DateTime? startTime,
    Duration? duration,
  }) {
    final sessionStart =
        startTime ?? DateTime.now().subtract(const Duration(hours: 4));
    final sessionDuration = duration ?? const Duration(hours: 4, minutes: 23);
    final sessionEnd = sessionStart.add(sessionDuration);

    // Generate trail visits
    final visits = <TrailVisit>[];
    var currentTime = sessionStart;

    // Simulate 12 runs (mix of trails and lifts)
    for (int i = 0; i < 12; i++) {
      // Lift ride up
      final liftVisit = _generateLiftVisit(
        currentTime: currentTime,
        duration: const Duration(minutes: 8),
      );
      visits.add(liftVisit);
      currentTime = liftVisit.endTime;

      // Short pause at top
      currentTime = currentTime.add(const Duration(minutes: 2));

      // Ski run down
      final runVisit = _generateRunVisit(
        currentTime: currentTime,
        runNumber: i + 1,
      );
      visits.add(runVisit);
      currentTime = runVisit.endTime;

      // Short pause at bottom
      currentTime = currentTime.add(const Duration(minutes: 3));
    }

    // Calculate statistics
    final stats = _calculateStats(visits);

    return SkiSession(
      id: _uuid.v4(),
      startTime: sessionStart,
      endTime: sessionEnd,
      status: SessionStatus.completed,
      resortId: resortId,
      visits: visits,
      stats: stats,
    );
  }

  static TrailVisit _generateLiftVisit({
    required DateTime currentTime,
    required Duration duration,
  }) {
    final path = _generateLiftPath(duration);

    return TrailVisit(
      id: _uuid.v4(),
      trailId: 'tremblant_gondola',
      startTime: currentTime,
      endTime: currentTime.add(duration),
      isLift: true,
      path: path,
      maxSpeed: 18.0 + (DateTime.now().millisecond % 3), // 18-20 km/h
      verticalChange: 610.0, // Going up
      distance: 1200.0,
    );
  }

  static TrailVisit _generateRunVisit({
    required DateTime currentTime,
    required int runNumber,
  }) {
    // Vary trail difficulty
    final trails = [
      {'id': 'tremblant_nansen', 'duration': 6, 'speed': 42},
      {'id': 'tremblant_flying_mile', 'duration': 5, 'speed': 38},
      {'id': 'tremblant_dynamite', 'duration': 4, 'speed': 55},
    ];

    final trail = trails[runNumber % trails.length];
    final duration = Duration(minutes: trail['duration']! as int);
    final path = _generateRunPath(duration, trail['speed']! as int);

    return TrailVisit(
      id: _uuid.v4(),
      trailId: trail['id']! as String,
      startTime: currentTime,
      endTime: currentTime.add(duration),
      isLift: false,
      path: path,
      maxSpeed: (trail['speed']! as int).toDouble(),
      verticalChange: -610.0, // Going down
      distance: 1800.0 + (runNumber * 100),
    );
  }

  static List<LocationPoint> _generateLiftPath(Duration duration) {
    final points = <LocationPoint>[];
    final numPoints = duration.inSeconds ~/ 10; // Point every 10 seconds

    for (int i = 0; i < numPoints; i++) {
      final progress = i / numPoints;
      points.add(
        LocationPoint(
          latitude: 46.2065 + (progress * 0.003),
          longitude: -74.5905 + (progress * 0.003),
          altitude: 265 + (progress * 610),
          speed: 17.0 + (DateTime.now().millisecond % 3),
          heading: 45.0,
          accuracy: 8.0,
          timestamp: DateTime.now().add(Duration(seconds: i * 10)),
        ),
      );
    }

    return points;
  }

  static List<LocationPoint> _generateRunPath(Duration duration, int avgSpeed) {
    final points = <LocationPoint>[];
    final numPoints = duration.inSeconds ~/ 5; // Point every 5 seconds

    for (int i = 0; i < numPoints; i++) {
      final progress = i / numPoints;
      final speedVariation = (DateTime.now().millisecond % 10) - 5;

      points.add(
        LocationPoint(
          latitude: 46.2095 - (progress * 0.004),
          longitude: -74.5935 - (progress * 0.004),
          altitude: 875 - (progress * 610),
          speed: avgSpeed + speedVariation.toDouble(),
          heading: 225.0,
          accuracy: 6.0,
          timestamp: DateTime.now().add(Duration(seconds: i * 5)),
        ),
      );
    }

    return points;
  }

  static SessionStatistics _calculateStats(List<TrailVisit> visits) {
    double totalVertical = 0;
    double totalDistance = 0;
    double maxSpeed = 0;
    Duration timeSkiing = Duration.zero;
    Duration timeOnLift = Duration.zero;
    int greenTrails = 0;
    int blueTrails = 0;
    int blackTrails = 0;
    final trailCounts = <String, int>{};

    for (final visit in visits) {
      totalDistance += visit.distance;

      if (visit.maxSpeed > maxSpeed) {
        maxSpeed = visit.maxSpeed;
      }

      if (visit.isLift) {
        timeOnLift += visit.duration;
      } else {
        timeSkiing += visit.duration;
        totalVertical += visit.verticalChange.abs();

        // Count trails
        if (visit.trailId.contains('flying_mile')) {
          greenTrails++;
        } else if (visit.trailId.contains('nansen')) {
          blueTrails++;
        } else if (visit.trailId.contains('dynamite')) {
          blackTrails++;
        }

        trailCounts[visit.trailId] = (trailCounts[visit.trailId] ?? 0) + 1;
      }
    }

    final totalTime = timeSkiing + timeOnLift;
    final avgSpeed = totalTime.inSeconds > 0
        ? (totalDistance / 1000.0) / (totalTime.inSeconds / 3600.0)
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
      doubleBlackTrails: 0,
      trailCounts: trailCounts,
    );
  }

  /// Generate multiple mock sessions for history
  static List<SkiSession> generateMockHistory({
    required String resortId,
    int count = 5,
  }) {
    final sessions = <SkiSession>[];

    for (int i = 0; i < count; i++) {
      final daysAgo = i * 7; // One session per week
      final session = generateMockSession(
        resortId: resortId,
        startTime: DateTime.now().subtract(Duration(days: daysAgo, hours: 9)),
        duration: Duration(hours: 3 + (i % 3), minutes: 15 + (i * 10 % 45)),
      );
      sessions.add(session);
    }

    return sessions;
  }
}
