import 'package:meta/meta.dart';
import 'package:geopoint/geopoint.dart';
import 'package:ml_linalg/linalg.dart';
import 'convert.dart';
import '../types.dart';
/*
class GeoSerieTransform {
  /// Resample a time serie
  ///
  /// [GeoSerie] can be resampled by year, month, day,
  /// hours, minutes or seconds. The geoserie must not be null
  GeoSerie resample(GeoSerie geoSerie,
      {@required Duration timeFrame,
      @required TimestampType timestampType,
      @required GeoSerieResampleMethod method}) {
    assert(geoSerie != null);
    final series = _splitSerieFromDuration(geoSerie, timeFrame,
        timestampType: timestampType);
    return _resample(series, method);
  }

  GeoSerie _resample(
      List<List<GeoPoint>> series, GeoSerieResampleMethod method) {
    final res = GeoSerie();
    for (final serie in series) {
      final vectors = <String, Vector>{};
      try {
        vectors["speed"] = Vector.fromList(
            serie.map<double>((item) => item.speed ?? 0).toList());
      } catch (e) {
        throw ("Can not encode speed vector $e");
      }
      try {
        vectors["altitude"] = Vector.fromList(
            serie.map<double>((item) => item.altitude ?? 0).toList());
      } catch (e) {
        throw ("Can not encode altitude vector $e");
      }
      try {
        vectors["accuracy"] = Vector.fromList(
            serie.map<double>((item) => item.accuracy ?? 0).toList());
      } catch (e) {
        throw ("Can not encode accuracy vector $e");
      }
      try {
        vectors["speed_accuracy"] = Vector.fromList(
            serie.map<double>((item) => item.speedAccuracy ?? 0).toList());
      } catch (e) {
        throw ("Can not encode speed_accuracy vector $e");
      }
      // turn numeric properties into vectors
      final propertiesVectors = geoPointsNumericPropertiesToVectors(serie);
      print("PROP VECTORS: $propertiesVectors");

      // resample data
      double speed;
      double altitude;
      double accuracy;
      double speedAccuracy;
      final propVals = <String, double>{};
      switch (method) {
        case GeoSerieResampleMethod.mean:
          speed = vectors["speed"].mean();
          altitude = vectors["altitude"].mean();
          accuracy = vectors["accuracy"].mean();
          speedAccuracy = vectors["speed_accuracy"].mean();
          propertiesVectors.forEach((k, v) => propVals[k] = v.mean());
          break;
        case GeoSerieResampleMethod.sum:
          speed = vectors["speed"].sum();
          altitude = vectors["altitude"].sum();
          accuracy = vectors["accuracy"].sum();
          speedAccuracy = vectors["speed_accuracy"].sum();
          propertiesVectors.forEach((k, v) => propVals[k] = v.sum());
          break;
      }
      GeoPoint median;
      if (serie.length < 3) {
        median = serie[0];
      } else {
        median = serie[int.parse("${(serie.length / 2).toStringAsFixed(0)}")];
      }
      final props = Set<GeoPointProperty>();
      propVals.forEach(
          (k, v) => props.add(GeoPointProperty<double>(name: k, value: v)));
      props.add(GeoPointProperty<double>(
          name: "resampled_points", value: serie.length.toDouble()));
      final geoPoint = GeoPoint(
          timestamp: median.timestamp,
          properties: props,
          latitude: median.latitude,
          longitude: median.longitude,
          speed: speed,
          altitude: altitude,
          accuracy: accuracy,
          speedAccuracy: speedAccuracy);
      res.geoPoints.add(geoPoint);
    }
    return res;
  }

  List<List<GeoPoint>> _splitSerieFromDuration(
      GeoSerie geoSerie, Duration timeFrame,
      {@required TimestampType timestampType}) {
    final res = <List<GeoPoint>>[];
    final startDate = geoSerie.dates(timestampType: timestampType).first;
    var nextDate = startDate.add(timeFrame);
    var subSerie = <GeoPoint>[];
    for (final geoPoint in geoSerie.geoPoints) {
      final date = geoPoint.date(timestampType: timestampType);
      if (date.isBefore(nextDate)) {
        subSerie.add(geoPoint);
      } else {
        res.add(subSerie);
        subSerie = <GeoPoint>[geoPoint];
        nextDate = date.add(timeFrame);
      }
    }
    return res;
  }
}*/
