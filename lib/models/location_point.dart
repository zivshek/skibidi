/// Represents a geographic point with location data
class LocationPoint {
  final double latitude;
  final double longitude;
  final double? altitude; // in meters
  final double? speed; // in km/h
  final double? heading; // in degrees
  final double accuracy; // in meters
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    required this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'speed': speed,
    'heading': heading,
    'accuracy': accuracy,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LocationPoint.fromJson(Map<String, dynamic> json) => LocationPoint(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    altitude: json['altitude'] as double?,
    speed: json['speed'] as double?,
    heading: json['heading'] as double?,
    accuracy: json['accuracy'] as double,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
