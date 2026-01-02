import 'package:flutter/material.dart';

/// Trail difficulty levels (mapped from OSM piste:difficulty)
enum TrailDifficulty {
  green, // novice, easy
  blue, // intermediate
  black, // advanced
  doubleBlack, // expert
}

extension TrailDifficultyExtension on TrailDifficulty {
  /// Get display name for difficulty
  String get displayName {
    switch (this) {
      case TrailDifficulty.green:
        return 'Green';
      case TrailDifficulty.blue:
        return 'Blue';
      case TrailDifficulty.black:
        return 'Black';
      case TrailDifficulty.doubleBlack:
        return 'Double Black';
    }
  }

  /// Get color for difficulty
  Color get color {
    switch (this) {
      case TrailDifficulty.green:
        return const Color(0xFF4CAF50); // Green
      case TrailDifficulty.blue:
        return const Color(0xFF2196F3); // Blue
      case TrailDifficulty.black:
        return const Color(0xFF212121); // Black
      case TrailDifficulty.doubleBlack:
        return const Color(0xFF000000); // Pure Black
    }
  }

  /// Parse from OSM piste:difficulty tag
  static TrailDifficulty? fromOsmTag(String? tag) {
    if (tag == null) return null;
    switch (tag.toLowerCase()) {
      case 'novice':
      case 'easy':
        return TrailDifficulty.green;
      case 'intermediate':
        return TrailDifficulty.blue;
      case 'advanced':
        return TrailDifficulty.black;
      case 'expert':
      case 'freeride':
        return TrailDifficulty.doubleBlack;
      default:
        return null;
    }
  }
}

/// Represents a ski trail/piste
class Trail {
  final String id;
  final String name;
  final TrailDifficulty difficulty;
  final String resortId;
  final List<List<double>> coordinates; // [[lng, lat], ...] GeoJSON format
  final double? topElevation; // in meters
  final double? bottomElevation; // in meters
  final bool isGroomed;

  const Trail({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.resortId,
    required this.coordinates,
    this.topElevation,
    this.bottomElevation,
    this.isGroomed = true,
  });

  /// Calculate vertical drop
  double? get verticalDrop {
    if (topElevation != null && bottomElevation != null) {
      return topElevation! - bottomElevation!;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'difficulty': difficulty.name,
    'resortId': resortId,
    'coordinates': coordinates,
    'topElevation': topElevation,
    'bottomElevation': bottomElevation,
    'isGroomed': isGroomed,
  };

  factory Trail.fromJson(Map<String, dynamic> json) => Trail(
    id: json['id'] as String,
    name: json['name'] as String,
    difficulty: TrailDifficulty.values.firstWhere(
      (e) => e.name == json['difficulty'],
    ),
    resortId: json['resortId'] as String,
    coordinates: (json['coordinates'] as List)
        .map((coord) => (coord as List).cast<double>())
        .toList(),
    topElevation: json['topElevation'] as double?,
    bottomElevation: json['bottomElevation'] as double?,
    isGroomed: json['isGroomed'] as bool? ?? true,
  );
}
