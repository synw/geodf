/// An exception for an unsupported geosjon feature
class UnsupportedGeoJsonFeatureError implements Exception {
  UnsupportedGeoJsonFeatureError(this.message);

  /// The error message
  final String message;
}

/// An exception for an unsupported geosjon feature
class UnknownGeometryTypeError implements Exception {
  UnknownGeometryTypeError(this.message);

  /// The error message
  final String message;
}

/// An exception for type conversions errors
class TypeConversionError implements Exception {
  TypeConversionError(this.message);

  /// The error message
  final String message;
}

/// An exception for data not found
class DataNotFoundError implements Exception {
  DataNotFoundError(this.message);

  /// The error message
  final String message;
}
