/// Constants for GPS tracking and activity detection
class TrackingConstants {
  /// Minimum accuracy required for GPS points (meters)
  static const double minAccuracy = 20.0;

  /// Location update interval when actively tracking (seconds)
  static const int locationUpdateInterval = 3;

  /// Speed threshold to detect skiing vs stationary (km/h)
  static const double movingSpeedThreshold = 2.0;

  /// Speed threshold to detect lift ride (km/h)
  /// Lifts typically move at 5-20 km/h while ascending
  static const double liftSpeedThreshold = 15.0;

  /// Minimum altitude change to detect lift vs run (meters)
  /// Positive = going up (lift), Negative = going down (run)
  static const double liftAltitudeThreshold = 10.0;

  /// Time threshold to start a new trail visit (seconds)
  /// If no movement for this long, consider it a break
  static const int inactivityThreshold = 180; // 3 minutes

  /// Minimum distance to consider as a valid run (meters)
  static const double minRunDistance = 100.0;

  /// Maximum distance from trail to consider user on trail (meters)
  static const double maxDistanceFromTrail = 50.0;
}
