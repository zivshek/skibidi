import 'package:skibidi/models/trail_visit.dart';
import 'package:skibidi/models/session_statistics.dart';

/// Status of a ski session
enum SessionStatus {
  active, // Currently tracking
  paused, // Temporarily paused
  completed, // Session ended
}

/// Represents a skiing session
class SkiSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;
  final String resortId;
  final List<TrailVisit> visits;
  final SessionStatistics stats;

  const SkiSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.resortId,
    required this.visits,
    required this.stats,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'status': status.name,
    'resortId': resortId,
    'visits': visits.map((v) => v.toJson()).toList(),
    'stats': stats.toJson(),
  };

  factory SkiSession.fromJson(Map<String, dynamic> json) => SkiSession(
    id: json['id'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null
        ? DateTime.parse(json['endTime'] as String)
        : null,
    status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
    resortId: json['resortId'] as String,
    visits: (json['visits'] as List)
        .map((v) => TrailVisit.fromJson(v as Map<String, dynamic>))
        .toList(),
    stats: SessionStatistics.fromJson(json['stats'] as Map<String, dynamic>),
  );

  /// Create a new session
  factory SkiSession.create({required String id, required String resortId}) =>
      SkiSession(
        id: id,
        startTime: DateTime.now(),
        status: SessionStatus.active,
        resortId: resortId,
        visits: [],
        stats: SessionStatistics.empty(),
      );
}
