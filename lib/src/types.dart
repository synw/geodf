enum GeoDataFrameColumnType { categorical, numeric, time, geometry }

enum TimelineSequenceType { moving, stopped, unknown }

/// Type of the timestamp
enum TimestampType {
  /// Seconds from epoch
  seconds,

  /// Milliseconds from epoch
  milliseconds,

  /// Micorseconds from epoch
  microseconds
}

enum GeoSerieResampleMethod { sum, mean }
