/// Statistics for a ski session
class SessionStatistics {
  final double totalVertical; // meters descended
  final double totalDistance; // meters
  final double maxSpeed; // km/h
  final double avgSpeed; // km/h
  final Duration timeSkiing;
  final Duration timeOnLift;
  final int greenTrails;
  final int blueTrails;
  final int blackTrails;
  final int doubleBlackTrails;
  final Map<String, int> trailCounts; // trailId -> count

  const SessionStatistics({
    required this.totalVertical,
    required this.totalDistance,
    required this.maxSpeed,
    required this.avgSpeed,
    required this.timeSkiing,
    required this.timeOnLift,
    required this.greenTrails,
    required this.blueTrails,
    required this.blackTrails,
    required this.doubleBlackTrails,
    required this.trailCounts,
  });

  int get totalRuns =>
      greenTrails + blueTrails + blackTrails + doubleBlackTrails;

  Duration get totalTime => timeSkiing + timeOnLift;

  Map<String, dynamic> toJson() => {
    'totalVertical': totalVertical,
    'totalDistance': totalDistance,
    'maxSpeed': maxSpeed,
    'avgSpeed': avgSpeed,
    'timeSkiing': timeSkiing.inSeconds,
    'timeOnLift': timeOnLift.inSeconds,
    'greenTrails': greenTrails,
    'blueTrails': blueTrails,
    'blackTrails': blackTrails,
    'doubleBlackTrails': doubleBlackTrails,
    'trailCounts': trailCounts,
  };

  factory SessionStatistics.fromJson(Map<String, dynamic> json) =>
      SessionStatistics(
        totalVertical: json['totalVertical'] as double,
        totalDistance: json['totalDistance'] as double,
        maxSpeed: json['maxSpeed'] as double,
        avgSpeed: json['avgSpeed'] as double,
        timeSkiing: Duration(seconds: json['timeSkiing'] as int),
        timeOnLift: Duration(seconds: json['timeOnLift'] as int),
        greenTrails: json['greenTrails'] as int,
        blueTrails: json['blueTrails'] as int,
        blackTrails: json['blackTrails'] as int,
        doubleBlackTrails: json['doubleBlackTrails'] as int,
        trailCounts: Map<String, int>.from(json['trailCounts'] as Map),
      );

  /// Create empty statistics
  factory SessionStatistics.empty() => const SessionStatistics(
    totalVertical: 0,
    totalDistance: 0,
    maxSpeed: 0,
    avgSpeed: 0,
    timeSkiing: Duration.zero,
    timeOnLift: Duration.zero,
    greenTrails: 0,
    blueTrails: 0,
    blackTrails: 0,
    doubleBlackTrails: 0,
    trailCounts: {},
  );
}
