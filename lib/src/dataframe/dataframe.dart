import 'dart:math';

import 'package:df/df.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:meta/meta.dart';
import 'package:ml_linalg/linalg.dart';

import '../exceptions.dart';
import '../geodesy.dart';
import '../infer.dart';
import '../types.dart';
import 'column.dart';

/// A geo dataframe
class GeoDataFrame extends DataFrame {
  GeoDataFrameColumn _timeCol;
  GeoDataFrameColumn _geometryCol;
  GeoDataFrameColumn _speedCol;

  /// Create an empty dataframe from
  GeoDataFrame.fromFeatureColumns({
    @required Type geometryType,
    String speedCol = "speed",
    String geometryCol = "geometry",
    String timeCol = "timestamp",
  }) {
    _speedCol = GeoDataFrameColumn(
        name: speedCol, dtype: GeoDataFrameColumnType.numeric, type: double);
    _timeCol = GeoDataFrameColumn(
        name: timeCol, dtype: GeoDataFrameColumnType.time, type: DateTime);
    _geometryCol = GeoDataFrameColumn(
        name: geometryCol,
        dtype: GeoDataFrameColumnType.geometry,
        type: geometryType);
    setColumns(<DataFrameColumn>[
      DataFrameColumn(name: speedCol, type: double),
      DataFrameColumn(name: timeCol, type: DateTime),
      DataFrameColumn(name: geometryCol, type: geometryType),
    ]);
  }

  /// Create a dataframe from a geojson feature collection
  GeoDataFrame.fromGeoJson(GeoJsonFeatureCollection featureCollection,
      {String timestampProperty = "timestamp",
      String speedProperty = "speed",
      TimestampType timestampFormat = TimestampType.milliseconds,
      bool verbose = false}) {
    var i = 0;
    if (verbose) {
      print("Processing geojson features");
    }
    for (final feat in featureCollection.collection) {
      // if first object guess the columns
      if (i == 0) {
        // geometry col
        _geometryCol =
            GeoDataFrameColumn.fromGeoJsonGeometry(feat.geometry, "geometry")
              ..indice = i;
        columns.add(_geometryCol);
        // time col
        if (timestampProperty != null) {
          _timeCol = GeoDataFrameColumn(
              name: timestampProperty,
              dtype: GeoDataFrameColumnType.time,
              type: DateTime)
            ..indice = i;
        }
        columns.add(_timeCol);
        // speed col
        if (speedProperty != null) {
          _speedCol = GeoDataFrameColumn(
              name: speedProperty,
              dtype: GeoDataFrameColumnType.numeric,
              type: double)
            ..indice = i;
        }
        columns.add(_speedCol);
        // properties
        feat.properties.forEach((k, dynamic v) {
          if (!<String>[speedProperty, timestampProperty, "geometry"]
              .contains(k)) {
            final col = GeoDataFrameColumn.inferFromDataPoint(v, k);
            columns.add(col);
          }
        });
        if (verbose) {
          print(
              "Loaded ${featureCollection.collection.length} geojson features");
        }
      }
      // process data
      final dataPoint = <dynamic>[];
      for (final col in columns) {
        if (col == _geometryCol) {
          switch (feat.type) {
            case GeoJsonFeatureType.point:
              dataPoint.add(feat.geometry.geoPoint);
              break;
            case GeoJsonFeatureType.multipoint:
              dataPoint.add(feat.geometry.geoSerie);
              break;
            case GeoJsonFeatureType.line:
              dataPoint.add(feat.geometry.geoSerie);
              break;
            default:
              throw UnsupportedGeoJsonFeatureError(
                  "Unsupported geojson feature type ${feat.type}");
          }
        } else if (col == _timeCol) {
          dataPoint.add(GeoDataFrameColumn.dateFromInt(
              int.parse(feat.properties[timestampProperty].toString()),
              timestampFormat));
        } else {
          dataPoint.add(feat.properties[col.name]);
        }
      }
      addRecords(<dynamic>[dataPoint]);
      //_dataMatrix.add(dataPoint);
      ++i;
    }
  }

  /// Create an empty dataframe from records
  factory GeoDataFrame.emptyfromRecord(Map<String, dynamic> record,
      {@required String geometryCol,
      String speedCol,
      String timeCol,
      bool verbose = false}) {
    assert(record.isNotEmpty);
    return GeoDataFrame._fromRecords(<Map<String, dynamic>>[record],
        geometryCol: geometryCol,
        speedCol: speedCol,
        timeCol: timeCol,
        verbose: verbose,
        forceEmpty: true);
  }

  /// Create a dataframe from records
  factory GeoDataFrame.fromRecords(List<Map<String, dynamic>> records,
      {@required String geometryCol,
      String speedCol,
      String timeCol,
      bool verbose = false}) {
    assert(records.isNotEmpty);
    return GeoDataFrame._fromRecords(records,
        geometryCol: geometryCol,
        speedCol: speedCol,
        timeCol: timeCol,
        verbose: verbose);
  }

  GeoDataFrame._fromRecords(List<Map<String, dynamic>> records,
      {@required String geometryCol,
      String speedCol,
      String timeCol,
      //TimestampType timestampFormat = TimestampType.milliseconds,
      bool verbose = false,
      bool forceEmpty = false}) {
    // feature columns
    // create geometry col
    //print("RECORD ${records[0]}");
    //assert(records[0].containsKey(geometryCol));
    //assert(records[0][geometryCol] != null);
    final dfCols = <DataFrameColumn>[];
    final geomType = inferGeometryType(records[0][geometryCol]);
    _geometryCol = GeoDataFrameColumn(
        name: geometryCol,
        dtype: GeoDataFrameColumnType.geometry,
        type: geomType);
    dfCols.add(DataFrameColumn(name: geometryCol, type: geomType));
    // time col
    if (timeCol != null) {
      _timeCol = GeoDataFrameColumn(
          name: timeCol, dtype: GeoDataFrameColumnType.time, type: DateTime);
      dfCols.add(DataFrameColumn(name: timeCol, type: DateTime));
    }
    // speed col
    if (speedCol != null) {
      _speedCol = GeoDataFrameColumn(
          name: speedCol, dtype: GeoDataFrameColumnType.numeric, type: double);
      dfCols.add(DataFrameColumn(name: speedCol, type: double));
    }
    // create regular cols infering their type from the first record
    //print("COLUMNS $columns");
    for (final columnName in records[0].keys) {
      if (columnsNames.contains(columnName)) {
        continue;
      }
      final col = GeoDataFrameColumn.inferFromDataPoint(
          records[0][columnName], columnName);
      dfCols.add(DataFrameColumn(name: col.name, type: col.type));
    }
    setColumns(dfCols);
    if (!forceEmpty) {
      // fill the data
      for (final record in records) {
        final line = <dynamic>[];
        columnsIndices.forEach((i, colName) {
          line.add(record[colName]);
        });
        addRecords(line);
        // _dataMatrix.add(line);
      }
    }
    if (verbose) {
      print("Created a dataframe with $length datapoints");
    }
  }

  /// Create a dataframe filled with random data
  factory GeoDataFrame.random(
      {double distance = 10.0,
      double speed,
      Duration timeInterval = const Duration(seconds: 10),
      double bearing = 142.0,
      double startLatitude = 51.0,
      double startLongitude = 0.0,
      int numRecords = 100,
      bool verbose = false}) {
    final data = <Map<String, dynamic>>[];
    final geodesy = Geodesy();
    var prevPoint =
        GeoPoint(latitude: startLatitude, longitude: startLongitude);
    var prevDate = DateTime.now().subtract(timeInterval * numRecords);
    var i = 0;
    // data
    while (i < numRecords) {
      final line = <String, dynamic>{};
      final newPoint = geodesy.destinationPointByDistanceAndBearing(
          prevPoint.toLatLng(), distance, bearing);
      line["geometry"] = GeoPoint.fromLatLng(point: newPoint);
      prevPoint = GeoPoint.fromLatLng(point: newPoint);
      final nextDate = prevDate.add(timeInterval);
      line["timestamp"] = nextDate;
      prevDate = nextDate;
      var s = speed;
      if (speed == null) {
        s = Random().nextDouble() * 10;
      }
      line["speed"] = s;
      line["bearing"] = bearing;
      data.add(line);
      ++i;
    }
    return GeoDataFrame.fromRecords(data,
        geometryCol: "geometry",
        speedCol: "speed",
        timeCol: "timestamp",
        verbose: verbose);
  }

  GeoDataFrame._copyWithMatrix(GeoDataFrame df, List<List<dynamic>> matrix) {
    _timeCol = df._timeCol;
    _geometryCol = df._geometryCol;
    _speedCol = df._speedCol;
    setColumns(df.columns);
    dataset = matrix;
  }

  GeoDataFrame._empty();

  // ********* computed properties **********

  /// The average speed
  double get avgSpeed => _avgSpeed();

  /// The average speed when moving
  double get avgSpeedWhenMoving => _avgSpeed(moving: true);

  /// The max speed
  double get maxSpeed => _maxSpeed();

  /// The max speed when moving
  double get maxSpeedWhenMoving => _maxSpeed(moving: true);

  /// The total distance
  double get distance => _distance();

  //String get duration => formatDuration(_duration());

  /// The feature columns
  GeoDataFrameFeatureColumns get featureCols => GeoDataFrameFeatureColumns(
      geometry: _geometryCol, time: _timeCol, speed: _speedCol);

  // ***********************
  // Properties
  // ***********************

  /// The geometry column
  GeoDataFrameColumn get geometryCol => _geometryCol;

  /// The speed column
  GeoDataFrameColumn get speedCol => _speedCol;

  /// The time column
  GeoDataFrameColumn get timeCol => _timeCol;

  //List<DateTime> get timeRecords => _timeRecords();

  // ***********************
  // Methods
  // ***********************

  // ********* sequence detection **********

  /* double meanDoubleCol(String columnName) =>
      data.meanDoubleCol(_indiceForColumn(columnName));

  double meanDoubleColRounded(String columnName, {int precision = 1}) =>
      double.parse(meanDoubleCol(columnName).toStringAsFixed(precision));

  Future<TimelineScene> moves(
      {Duration minStopDuration = const Duration(seconds: 30)}) async {
    assert(_speedCol != null);
    assert(_timeCol != null);
    final sequences = <TimelineSequence>[];
    var currentSequence =
        TimelineSequence(timeColName: _timeCol.name, startIndex: 0);
    final df = sort(_timeCol.name);
    DateTime lastPointDate;
    var i = 0;
    await for (final row in df._iter()) {
      final speed = double.tryParse(row[_speedCol.name].toString()) ?? 0.0;
      // start a new sequence: detect type of sequence
      if (currentSequence.type == TimelineSequenceType.unknown) {
        currentSequence.type = TimelineSequenceType.stopped;
        if (speed > 0) {
          currentSequence.type = TimelineSequenceType.moving;
        }
      }
      final indices = _columnsIndices();
      // detect serie end
      //print("ROW $row");
      //print("$i SEQ $currentSequence ${row[_speedCol.name]} / $speed");
      switch (currentSequence.type) {
        case TimelineSequenceType.stopped:
          if (speed > 0) {
            currentSequence
              ..endIndex = i
              ..data = _dataMatrix.dataForIndexRange(currentSequence.startIndex,
                  currentSequence.endIndex, indices);
            sequences.add(currentSequence);
            currentSequence = TimelineSequence(
                timeColName: _timeCol.name,
                type: TimelineSequenceType.moving,
                startIndex: i + 1);
          }
          break;
        case TimelineSequenceType.moving:
          var endSequence = false;
          // if not first row
          if (lastPointDate != null) {
            final durationFromLastPoint =
                (row[_timeCol.name] as DateTime).difference(lastPointDate);
            //print("DUR $durationFromLastPoint");
            if (speed == 0 && (durationFromLastPoint > minStopDuration)) {
              endSequence = true;
            }
          }
          // end sequence of finished parsing
          final isEnd = i == (df.length - 1);
          //print("IS END $isEnd");
          if (endSequence || isEnd) {
            currentSequence
              ..endIndex = i
              ..data = _dataMatrix.dataForIndexRange(currentSequence.startIndex,
                  currentSequence.endIndex, indices);
            sequences.add(currentSequence);
            currentSequence = TimelineSequence(
                timeColName: _timeCol.name,
                type: TimelineSequenceType.stopped,
                startIndex: i + 1);
          }
          break;
        default:
      }
      lastPointDate = row[_timeCol.name] as DateTime;
      ++i;
    }
    return TimelineScene(sequences: sequences);
  }*/

  // ***********************
  // Internal methods
  // ***********************

  double _distance() {
    var geoPoints = <GeoPoint>[];
    switch (_geometryCol.type) {
      case GeoPoint:
        geoPoints = colRecords<GeoPoint>(_geometryCol.name);
        break;
      case GeoSerie:
        final series = colRecords<GeoSerie>(_geometryCol.name);
        for (final serie in series) {
          geoPoints.addAll(serie.geoPoints);
        }
    }
    return geoPointsDistance(geoPoints);
  }

/*  Duration _duration() {
    assert(_timeCol != null);
    String sortCol;
    _sort(_timeCol.name, inPlace: true);
    final tr = _timeRecords();
    final d = tr[tr.length - 1].difference(tr[0]);
    if (sortCol != null) {
      _sort(sortCol, inPlace: true);
    }
    return d;
  }*/

  double _maxSpeed({bool moving = false}) =>
      _speedCalc(moving: moving, max: true);

  double _avgSpeed({bool moving = false}) => _speedCalc(moving: moving);

  double _speedCalc({bool moving = false, bool max = false}) {
    assert(_speedCol != null);
    final dataPoints = colRecords<double>(_speedCol.name);
    /* switch (dataPoints.length) {
      case 0:
        return 0;
        break;
      case 1:
        if (moving) {
          final val = dataPoints[0];
          if (val > 0) {
            return val;
          } else {
            return 0;
          }
        }
    }*/
    //print("SPEED DATA $data");
    final points = <double>[];
    for (final value in dataPoints) {
      if (value != null) {
        final val = double.parse(value.toString());
        if (!moving) {
          points.add(val);
        } else {
          if (val > 0) {
            points.add(val);
          }
        }
      }
    }
    if (points.isEmpty) {
      return 0;
    }
    //print("VECTOR FROM POINTs $points");
    final vector = Vector.fromList(points);
    //print("AVG SPEED ${vector.mean()} / ${points.length} points");
    double res;
    switch (max) {
      case true:
        res = vector.max();
        break;
      default:
        res = vector.mean();
    }
    return res;
  }
/*

  List<DateTime> _timeRecords() {
    assert(_timeCol != null);
    final d = _dataMatrix
        .typedRecordsForColumnIndice<DateTime>(_indiceForColumn(_timeCol.name));
    return d;
  }

  static Future<GeoDataFrame> fromGeoJsonFile(String path,
      {String timestampProperty = "timestamp",
      String speedProperty = "speed",
      TimestampType timestampFormat = TimestampType.milliseconds,
      bool verbose = false}) async {
    if (verbose) {
      print("Loading geojson file $path");
    }
    final featureCollection = await featuresFromGeoJsonFile(File(path));
    return GeoDataFrame.fromGeoJson(featureCollection,
        speedProperty: speedProperty,
        timestampProperty: timestampProperty,
        timestampFormat: timestampFormat,
        verbose: verbose);
  } */
}
