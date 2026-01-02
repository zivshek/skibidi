import 'package:skibidi/models/resort.dart';
import 'package:skibidi/models/trail.dart';
import 'package:skibidi/models/lift.dart';

/// Interface for trail data repository - allows swapping data sources
/// Current implementation: OpenSkiMapTrailRepository
/// Alternative implementations: CustomApiTrailRepository, etc.
abstract class ITrailDataRepository {
  /// Get all available ski resorts
  Future<List<Resort>> getAllResorts();

  /// Get a specific resort by ID
  Future<Resort?> getResortById(String id);

  /// Get all trails for a specific resort
  Future<List<Trail>> getTrailsForResort(String resortId);

  /// Get all lifts for a specific resort
  Future<List<Lift>> getLiftsForResort(String resortId);

  /// Refresh/reload data (for future remote updates)
  Future<void> refreshData();
}
