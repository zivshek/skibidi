import 'package:skibidi/models/location_point.dart';

/// Represents a single visit to a trail during a session
class TrailVisit {
  final String id;
  final String trailId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isLift; // true if lift ride, false if skiing
  final List<LocationPoint> path; // GPS breadcrumbs
  final double maxSpeed; // km/h
  final double verticalChange; // meters (positive for lifts, negative for runs)
  final double distance; // meters

  const TrailVisit({
    required this.id,
    required this.trailId,
    required this.startTime,
    required this.endTime,
    required this.isLift,
    required this.path,
    required this.maxSpeed,
    required this.verticalChange,
    required this.distance,
  });

  Duration get duration => endTime.difference(startTime);

  double get averageSpeed {
    final hours = duration.inSeconds / 3600.0;
    return hours > 0 ? (distance / 1000.0) / hours : 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trailId': trailId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'isLift': isLift,
    'path': path.map((p) => p.toJson()).toList(),
    'maxSpeed': maxSpeed,
    'verticalChange': verticalChange,
    'distance': distance,
  };

  factory TrailVisit.fromJson(Map<String, dynamic> json) => TrailVisit(
    id: json['id'] as String,
    trailId: json['trailId'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    isLift: json['isLift'] as bool,
    path: (json['path'] as List)
        .map((p) => LocationPoint.fromJson(p as Map<String, dynamic>))
        .toList(),
    maxSpeed: json['maxSpeed'] as double,
    verticalChange: json['verticalChange'] as double,
    distance: json['distance'] as double,
  );
}
