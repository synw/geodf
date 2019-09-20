import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:meta/meta.dart';
import '../types.dart';

class GeoDataFrameColumn {
  GeoDataFrameColumn({this.name, this.dtype, this.type, this.indice});

  String name;
  GeoDataFrameColumnType dtype;
  Type type;
  int indice;

  GeoDataFrameColumn.fromGeoJsonGeometry(dynamic geometry, String columnName)
      : assert(columnName != null),
        assert(geometry != null) {
    name = columnName;
    if (geometry is GeoJsonPoint) {
      dtype = GeoDataFrameColumnType.geometry;
      type = GeoPoint;
    } else if (geometry is GeoJsonMultiPoint) {
      dtype = GeoDataFrameColumnType.geometry;
      type = GeoSerie;
    } else if (geometry is GeoJsonLine) {
      dtype = GeoDataFrameColumnType.geometry;
      type = GeoSerie;
    } else {
      throw ("Unsupported geometry $geometry");
    }
  }

  /// Infer the column types from a datapoint
  GeoDataFrameColumn.inferFromDataPoint(dynamic dataPoint, String columnName)
      : assert(columnName != null),
        assert(dataPoint != null) {
    name = columnName;
    if (dataPoint is int) {
      dtype = GeoDataFrameColumnType.numeric;
      type = int;
    } else if (dataPoint is double) {
      dtype = GeoDataFrameColumnType.numeric;
      type = double;
    } else if (dataPoint is String) {
      dtype = GeoDataFrameColumnType.categorical;
      type = String;
    } else if (dataPoint is DateTime) {
      dtype = GeoDataFrameColumnType.time;
      type = double;
    } else if (dataPoint is GeoPoint) {
      type = GeoPoint;
      dtype = GeoDataFrameColumnType.geometry;
    } else if (dataPoint is GeoSerie) {
      type = GeoSerie;
      dtype = GeoDataFrameColumnType.geometry;
    } else {
      dtype = GeoDataFrameColumnType.categorical;
      type = String;
    }
  }

  static List<GeoDataFrameColumn> defaultColumns() {
    final cols = <GeoDataFrameColumn>[
      GeoDataFrameColumn(
          name: "geometry",
          dtype: GeoDataFrameColumnType.geometry,
          type: GeoPoint),
      GeoDataFrameColumn(
          name: "timestamp", dtype: GeoDataFrameColumnType.time, type: int),
      GeoDataFrameColumn(
          name: "speed", dtype: GeoDataFrameColumnType.numeric, type: GeoPoint),
      GeoDataFrameColumn(
          name: "bearing", dtype: GeoDataFrameColumnType.numeric, type: double),
    ];
    return cols;
  }

  static GeoDataFrameColumn fromName(
      String name, List<GeoDataFrameColumn> columns) {
    for (final c in columns) {
      if (c.name == name) {
        return c;
      }
    }
    return null;
  }

  static DateTime dateFromInt(int dateObj, TimestampType timestampFormat) {
    assert(dateObj != null);
    DateTime date;
    switch (timestampFormat) {
      case TimestampType.milliseconds:
        date = DateTime.fromMillisecondsSinceEpoch(dateObj);
        break;
      case TimestampType.seconds:
        date = DateTime.fromMillisecondsSinceEpoch(dateObj * 1000);
        break;
      case TimestampType.microseconds:
        date = DateTime.fromMicrosecondsSinceEpoch(dateObj);
        break;
    }
    return date;
  }

  @override
  String toString() {
    return "$name ($dtype) with $type data";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoDataFrameColumn &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class GeoDataFrameFeatureColumns {
  GeoDataFrameFeatureColumns(
      {@required this.time, @required this.geometry, @required this.speed});

  final GeoDataFrameColumn time;
  final GeoDataFrameColumn geometry;
  final GeoDataFrameColumn speed;
}
