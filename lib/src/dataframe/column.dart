import 'package:df/df.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:meta/meta.dart';

import '../exceptions.dart';
import '../types.dart';

class GeoDataFrameColumn extends DataFrameColumn {
  GeoDataFrameColumnType dtype;
  int indice;
  GeoDataFrameColumn({String name, this.dtype, Type type, this.indice}) {
    super.name = name;
    super.type = type;
  }

  GeoDataFrameColumn.fromGeoJsonGeometry(dynamic geometry, String name)
      : assert(name != null),
        assert(geometry != null) {
    super.name = name;
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
      throw UnsupportedGeoJsonFeatureError("Unsupported geometry $geometry");
    }
  }

  /// Infer the column types from a datapoint
  GeoDataFrameColumn.inferFromDataPoint(dynamic dataPoint, String name)
      : assert(name != null),
        assert(dataPoint != null) {
    super.name = name;
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

  @override
  String toString() {
    return "$name ($dtype) with $type data";
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
}

class GeoDataFrameFeatureColumns {
  final GeoDataFrameColumn time;

  final GeoDataFrameColumn geometry;
  final GeoDataFrameColumn speed;
  GeoDataFrameFeatureColumns(
      {@required this.time, @required this.geometry, @required this.speed});
}
