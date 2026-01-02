/// Represents a ski resort
class Resort {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? region;
  final int? maxElevation; // in meters
  final int? minElevation; // in meters

  const Resort({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.region,
    this.maxElevation,
    this.minElevation,
  });

  int? get verticalDrop {
    if (maxElevation != null && minElevation != null) {
      return maxElevation! - minElevation!;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'region': region,
    'maxElevation': maxElevation,
    'minElevation': minElevation,
  };

  factory Resort.fromJson(Map<String, dynamic> json) => Resort(
    id: json['id'] as String,
    name: json['name'] as String,
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    country: json['country'] as String?,
    region: json['region'] as String?,
    maxElevation: json['maxElevation'] as int?,
    minElevation: json['minElevation'] as int?,
  );
}
