/// Represents a ski lift/aerial tramway
class Lift {
  final String id;
  final String name;
  final String resortId;
  final List<List<double>> coordinates; // [[lng, lat], ...] GeoJSON format
  final String? type; // chair, gondola, cable_car, etc.

  const Lift({
    required this.id,
    required this.name,
    required this.resortId,
    required this.coordinates,
    this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'resortId': resortId,
    'coordinates': coordinates,
    'type': type,
  };

  factory Lift.fromJson(Map<String, dynamic> json) => Lift(
    id: json['id'] as String,
    name: json['name'] as String,
    resortId: json['resortId'] as String,
    coordinates: (json['coordinates'] as List)
        .map((coord) => (coord as List).cast<double>())
        .toList(),
    type: json['type'] as String?,
  );
}
