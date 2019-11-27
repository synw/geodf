/// An exception for an unsupported geosjon feature
class UnsupportedGeoJsonFeatureError implements Exception {
  /// Default constructor
  UnsupportedGeoJsonFeatureError(this.message);

  /// The error message
  final String message;
}

/// An exception for an unsupported geosjon feature
class UnknownGeometryTypeError implements Exception {
  /// Default constructor
  UnknownGeometryTypeError(this.message);

  /// The error message
  final String message;
}

/// An exception for type conversions errors
class TypeConversionError implements Exception {
  /// Default constructor
  TypeConversionError(this.message);

  /// The error message
  final String message;
}

/// An exception for data not found
class DataNotFoundError implements Exception {
  /// Default constructor
  DataNotFoundError(this.message);

  /// The error message
  final String message;
}
