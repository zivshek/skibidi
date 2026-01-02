import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:skibidi/core/interfaces/i_trail_data_repository.dart';
import 'package:skibidi/models/resort.dart';
import 'package:skibidi/models/trail.dart';
import 'package:skibidi/models/lift.dart';

/// Implementation of trail data repository using OpenSkiMap GeoJSON format
/// Data is loaded from bundled assets
class OpenSkiMapTrailRepository implements ITrailDataRepository {
  final Map<String, Resort> _resortsCache = {};
  final Map<String, List<Trail>> _trailsCache = {};
  final Map<String, List<Lift>> _liftsCache = {};
  bool _initialized = false;

  /// Load data from assets on first access
  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    // For now, load Mont Tremblant data
    await _loadResortData('mont_tremblant');

    _initialized = true;
  }

  /// Load a single resort's data from GeoJSON file
  Future<void> _loadResortData(String resortId) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/trails/$resortId.geojson',
      );
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // Parse metadata
      final metadata = data['metadata'] as Map<String, dynamic>;
      final resort = Resort(
        id: metadata['resortId'] as String,
        name: metadata['resortName'] as String,
        latitude: metadata['latitude'] as double,
        longitude: metadata['longitude'] as double,
        country: metadata['country'] as String?,
        region: metadata['region'] as String?,
        maxElevation: metadata['maxElevation'] as int?,
        minElevation: metadata['minElevation'] as int?,
      );
      _resortsCache[resort.id] = resort;

      // Parse features (trails and lifts)
      final features = data['features'] as List<dynamic>;
      final trails = <Trail>[];
      final lifts = <Lift>[];

      for (final feature in features) {
        final featureMap = feature as Map<String, dynamic>;
        final properties = featureMap['properties'] as Map<String, dynamic>;
        final geometry = featureMap['geometry'] as Map<String, dynamic>;
        final coordinates = (geometry['coordinates'] as List)
            .map((coord) => (coord as List).cast<double>())
            .toList();

        // Check if it's a lift or trail
        if (properties['aerialway'] != null) {
          // It's a lift
          lifts.add(
            Lift(
              id: properties['id'] as String,
              name: properties['name'] as String,
              resortId: resort.id,
              coordinates: coordinates,
              type: properties['aerialway'] as String?,
            ),
          );
        } else if (properties['piste:type'] == 'downhill') {
          // It's a trail
          final difficulty = TrailDifficultyExtension.fromOsmTag(
            properties['piste:difficulty'] as String?,
          );

          if (difficulty != null) {
            // Use elevations from resort metadata
            final topElevation = resort.maxElevation?.toDouble();
            final bottomElevation = resort.minElevation?.toDouble();

            trails.add(
              Trail(
                id: properties['id'] as String,
                name: properties['name'] as String,
                difficulty: difficulty,
                resortId: resort.id,
                coordinates: coordinates,
                topElevation: topElevation,
                bottomElevation: bottomElevation,
                isGroomed: properties['piste:grooming'] != null,
              ),
            );
          }
        }
      }

      _trailsCache[resort.id] = trails;
      _liftsCache[resort.id] = lifts;
    } catch (e) {
      // Log error and continue with empty data
      print('Error loading resort data for $resortId: $e');
    }
  }

  @override
  Future<List<Resort>> getAllResorts() async {
    await _ensureInitialized();
    return _resortsCache.values.toList();
  }

  @override
  Future<Resort?> getResortById(String id) async {
    await _ensureInitialized();
    return _resortsCache[id];
  }

  @override
  Future<List<Trail>> getTrailsForResort(String resortId) async {
    await _ensureInitialized();
    return _trailsCache[resortId] ?? [];
  }

  @override
  Future<List<Lift>> getLiftsForResort(String resortId) async {
    await _ensureInitialized();
    return _liftsCache[resortId] ?? [];
  }

  @override
  Future<void> refreshData() async {
    _resortsCache.clear();
    _trailsCache.clear();
    _liftsCache.clear();
    _initialized = false;
    await _ensureInitialized();
  }
}
