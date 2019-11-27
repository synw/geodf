/// The internal type of a column
enum GeoDataFrameColumnType {
  /// Categorical column
  categorical,

  /// Numeric column
  numeric,

  /// Type column
  time,

  /// Geometry column
  geometry
}

/// Type of the timestamp
enum TimestampType {
  /// Seconds from epoch
  seconds,

  /// Milliseconds from epoch
  milliseconds,

  /// Micorseconds from epoch
  microseconds
}
