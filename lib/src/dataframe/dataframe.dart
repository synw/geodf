import 'dart:io';
import 'dart:math';

import 'package:geodesy/geodesy.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:meta/meta.dart';
import 'package:ml_linalg/linalg.dart';

import '../distance.dart' as dist;
import '../exceptions.dart';
import '../geodesy.dart';
import '../infer.dart';
import '../timeline/timeline.dart';
import '../types.dart';
import 'column.dart';
import 'info.dart';
import 'matrix.dart';

class GeoDataFrame {
  List<GeoDataFrameColumn> columns = <GeoDataFrameColumn>[];

  GeoDataFrame _backupDf;

  GeoDataFrameColumn _timeCol;
  GeoDataFrameColumn _geometryCol;
  GeoDataFrameColumn _speedCol;
  final _dataMatrix = GeoDataMatrix();
  final _info = GeoDataFrameInfo();
  String _isSortedBy;
  //final _geoSerieTransformer = GeoSerieTransform();

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
      _dataMatrix.add(dataPoint);
      ++i;
    }
  }

  factory GeoDataFrame.emptyfromRecord(Map<String, dynamic> record,
      {@required String geometryCol,
      String speedCol,
      String timestampCol,
      bool verbose = false}) {
    assert(record.isNotEmpty);
    return GeoDataFrame._fromRecords(<Map<String, dynamic>>[record],
        geometryCol: geometryCol,
        speedCol: speedCol,
        timestampCol: timestampCol,
        verbose: verbose,
        forceEmpty: true);
  }

  factory GeoDataFrame.fromRecords(List<Map<String, dynamic>> records,
      {@required String geometryCol,
      String speedCol,
      String timestampCol,
      bool verbose = false}) {
    assert(records.isNotEmpty);
    return GeoDataFrame._fromRecords(records,
        geometryCol: geometryCol,
        speedCol: speedCol,
        timestampCol: timestampCol,
        verbose: verbose);
  }

  GeoDataFrame._fromRecords(List<Map<String, dynamic>> records,
      {@required String geometryCol,
      String speedCol,
      String timestampCol,
      //TimestampType timestampFormat = TimestampType.milliseconds,
      bool verbose = false,
      bool forceEmpty = false}) {
    _backupDf = GeoDataFrame._empty();
    // feature columns
    // create geometry col
    //print("RECORD ${records[0]}");
    assert(records[0].containsKey(geometryCol));
    assert(records[0][geometryCol] != null);
    final geomType = inferGeometryType(records[0][geometryCol]);
    _geometryCol = GeoDataFrameColumn(
        name: geometryCol,
        dtype: GeoDataFrameColumnType.geometry,
        type: geomType);
    columns.add(_geometryCol);
    // time col
    if (timestampCol != null) {
      _timeCol = GeoDataFrameColumn(
          name: timestampCol,
          dtype: GeoDataFrameColumnType.time,
          type: DateTime);
      columns.add(_timeCol);
    }
    // speed col
    if (speedCol != null) {
      _speedCol = GeoDataFrameColumn(
          name: speedCol, dtype: GeoDataFrameColumnType.numeric, type: double);
      columns.add(_speedCol);
    }
    // create regular cols infering their type from the first record
    //print("COLUMNS $columns");
    for (final columnName in records[0].keys) {
      if (_columnsNames().contains(columnName)) {
        continue;
      }
      final col = GeoDataFrameColumn.inferFromDataPoint(
          records[0][columnName], columnName);
      columns.add(col);
    }
    if (!forceEmpty) {
      // fill the data
      final indices = _columnsIndices();
      for (final record in records) {
        final line = <dynamic>[];
        indices.forEach((i, colName) {
          line.add(record[colName]);
        });
        _dataMatrix.add(line);
      }
    }
    if (verbose) {
      print("Created a dataframe with $numRows datapoints");
    }
  }

  GeoDataFrame.fromTimelineSequence(
      GeoDataFrame df, TimelineSequence timelineSequence) {
    print("Create from timeline sequence: "
        "${timelineSequence.startIndex} -> ${timelineSequence.endIndex}"
        " / ${df.numRows}");
    _dataMatrix.data =
        df.rowsSubset(timelineSequence.startIndex, timelineSequence.endIndex);
    columns = df.columns;
    _timeCol = df._timeCol;
    _geometryCol = df._geometryCol;
    _speedCol = df._speedCol;
  }

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
        timestampCol: "timestamp",
        verbose: verbose);
  }

  GeoDataFrame._copyWithMatrix(GeoDataFrame df, List<List<dynamic>> matrix) {
    columns = df.columns;
    _dataMatrix.data = matrix;
    _timeCol = df._timeCol;
    _geometryCol = df._geometryCol;
    _speedCol = df._speedCol;
    _backupDf = df._backupDf;
  }

  GeoDataFrame._empty();

  double get avgSpeed => _avgSpeed();

  double get avgSpeedWhenMoving => _avgSpeed(moving: true);

  double get avgSpeedKmhRounded => round(3.6 * _avgSpeed(), decimals: 1);

  double get avgSpeedWhenMovingKmhRounded =>
      round(3.6 * _avgSpeed(moving: true), decimals: 1);

  double get maxSpeed => _avgSpeed();

  double get maxSpeedWhenMoving => _avgSpeed(moving: true);

  double get maxSpeedKmhRounded => round(3.6 * _maxSpeed(), decimals: 1);

  double get maxSpeedWhenMovingKmhRounded =>
      round(3.6 * _maxSpeed(moving: true), decimals: 1);

  // ********* computed properties **********

  GeoDataFrame get backupDf => _backupDf;

  List<String> get columnsNames => _columnsNames();

  List<List<dynamic>> get data => _dataMatrix.data;

  double get distance => _distance();

  double get distanceKmRounded => dist.kmRoundedFromMeters(_distance());

  String get duration => formatDuration(_duration());

  GeoDataFrameFeatureColumns get featureCols => GeoDataFrameFeatureColumns(
      geometry: _geometryCol, time: _timeCol, speed: _speedCol);

  // ***********************
  // Properties
  // ***********************

  GeoDataFrameColumn get geometryCol => _geometryCol;

  List<GeoPoint> get geoPoints => _geoPoints();

  int get numRows => _dataMatrix.data.length;

  GeoDataFrameColumn get speedCol => _speedCol;

  GeoDataFrameColumn get timeCol => _timeCol;

  List<DateTime> get timeRecords => _timeRecords();

  void backupI() {
    _backupDf ??= GeoDataFrame._empty();
    _backupDf
      ..columns = columns
      .._dataMatrix.data = _dataMatrix.data
      .._timeCol = _timeCol
      .._geometryCol = _geometryCol
      .._speedCol = _speedCol;
  }

  // ***********************
  // Methods
  // ***********************

  // ********* select operations **********

  List<T> colRecords<T>(String columnName) =>
      _dataMatrix.typedRecordsForColumnIndice<T>(_indiceForColumn(columnName));

  void cols() => _info.cols(columns: columns, featureColumns: featureCols);

  int countNulls(String columnName,
      {List<dynamic> nullValues = const <dynamic>[
        null,
        "null",
        "nan",
        "NULL",
        "N/A"
      ]}) {
    final n =
        _dataMatrix.countForValues(_indiceForColumn(columnName), nullValues);
    return n;
  }

  int countZeros(String columnName,
      {List<dynamic> zeroValues = const <dynamic>[0]}) {
    final n =
        _dataMatrix.countForValues(_indiceForColumn(columnName), zeroValues);
    return n;
  }

  List<Map<String, dynamic>> dataSubset(int startIndex, int endIndex) =>
      _dataMatrix.dataForIndexRange(startIndex, endIndex, _columnsIndices());

  void head([int lines = 5]) {
    print("${columns.length} columns: ${columnsNames.join(",")}");
    final rows = _dataMatrix.data.sublist(0, lines);
    _info.printRows(rows);
    print("$numRows rows");
  }

  void headCol(String columnName, {int lines = 10}) {
    final indice = _indiceForColumn(columnName);
    final records = _dataMatrix.recordsForColumnIndice(indice, limit: lines);
    print(
        "Column $columnName ($numRows records of type ${columns[indice].type}):");
    print(records.join(","));
  }

  Stream<Map<String, dynamic>> iter() => _iter();

  GeoDataFrame limit(int max, {int startIndex = 0}) {
    final _newMatrix = _dataMatrix.data.sublist(startIndex, startIndex + max);
    return GeoDataFrame._copyWithMatrix(this, _newMatrix);
  }

  void limitI(int max, {int startIndex = 0}) =>
      _dataMatrix.data = _dataMatrix.data.sublist(startIndex, startIndex + max);

  // ********* insert operations **********

  void addRecord(Map<String, dynamic> record) {
    final indices = _columnsIndices();
    final row = <dynamic>[];
    var i = 0;
    record.forEach((k, dynamic v) {
      final keyName = indices[i];
      row.add(record[keyName]);
      ++i;
    });
    _dataMatrix.add(row);
  }

  // ********* delete operations **********

  void removeRowAt(int index) => _dataMatrix.data.removeAt(index);

  void removeFirstRow() => _dataMatrix.data.removeAt(0);

  void removeLastRow() => _dataMatrix.data.removeLast();

  // ********* resample **********

  /* GeoSerie resampleSum(List<GeoPoint> geoPoints, Duration timeFrame) {
    final geoSerie = GeoSerie(geoPoints: geoPoints);
    final res = _geoSerieTransformer.resample(geoSerie,
        timeFrame: timeFrame,
        method: GeoSerieResampleMethod.sum,
        timestampType: TimestampType.milliseconds);
    return res;
  }

  GeoSerie resampleMean(List<GeoPoint> geoPoints, Duration timeFrame) {
    final geoSerie = GeoSerie(geoPoints: geoPoints);
    final res = _geoSerieTransformer.resample(geoSerie,
        timeFrame: timeFrame,
        method: GeoSerieResampleMethod.mean,
        timestampType: TimestampType.milliseconds);
    return res;
  }*/

  // ********* sequence detection **********

  double meanDoubleCol(String columnName) =>
      _dataMatrix.meanDoubleCol(_indiceForColumn(columnName));

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
          final isEnd = i == (df.numRows - 1);
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
  }

  void restoreI() {
    assert(_backupDf != null);
    columns = _backupDf.columns;
    _dataMatrix.data = _backupDf._dataMatrix.data;
    _timeCol = _backupDf._timeCol;
    _geometryCol = _backupDf._geometryCol;
    _speedCol = _backupDf._speedCol;
  }

// ********* count operations **********

  List<List<dynamic>> rowsSubset(int startIndex, int endIndex) =>
      _dataMatrix.rowsForIndexRange(startIndex, endIndex);

  void show([int lines = 5]) {
    print("${columns.length} columns and $numRows rows");
    head(lines);
  }

  GeoDataFrame sort(String columnName) => _sort(columnName);

  GeoDataFrame sortDesc(String columnName) => _sort(columnName, reverse: true);

  void sortDescI(String columnName) =>
      _sort(columnName, inPlace: true, reverse: true);

  void sortI(String columnName) => _sort(columnName, inPlace: true);

// ********* print info **********

  GeoDataFrame subset(int startIndex, int endIndex) {
    final _newMatrix = _dataMatrix.data.sublist(startIndex, endIndex);
    return GeoDataFrame._copyWithMatrix(this, _newMatrix);
  }

  double sumDoubleCol(String columnName) =>
      _dataMatrix.sumDoubleCol(_indiceForColumn(columnName));

  double sumDoubleColRounded(String columnName, {int precision = 1}) =>
      double.parse(sumDoubleCol(columnName).toStringAsFixed(precision));

  // ********* backup / restore **********

  Future<TimelineScene> timeSequences({@required Duration gap}) async {
    assert(_timeCol != null);
    final sequences = <TimelineSequence>[];
    var currentSequence =
        TimelineSequence(timeColName: _timeCol.name, startIndex: 0);
    DateTime previousDate;
    var i = 0;
    final indices = _columnsIndices();
    final df = _sort(_timeCol.name);
    await for (final row in df._iter()) {
      final dateValue = row[_timeCol.name] as DateTime;
      if (i == 0) {
        previousDate = dateValue;
      }
      var endSignal = false;
      if (row.containsKey("__endSignal__")) {
        if (row["__endSignal__"] == true) {
          endSignal = true;
        }
      }
      var timeDiff = const Duration(seconds: 0);
      if (!endSignal) {
        timeDiff = dateValue.difference(previousDate);
      }
      //print("TD $timeDiff / GAP $gap : ${timeDiff > gap}");
      if (timeDiff > gap || endSignal) {
        currentSequence
          ..endIndex = i + 1
          ..data = _dataMatrix.dataForIndexRange(
              currentSequence.startIndex, currentSequence.endIndex, indices);
        sequences.add(currentSequence);
        currentSequence =
            TimelineSequence(timeColName: _timeCol.name, startIndex: i);
      }
      previousDate = dateValue;
      ++i;
    }
    return TimelineScene(sequences: sequences);
  }

  // ***********************
  // Internal methods
  // ***********************

  Map<dynamic, int> _columnDataWithIndex(int colIndice) {
    final res = <dynamic, int>{};
    var i = 0;
    for (final row in _dataMatrix.data) {
      res[row[colIndice]] = i;
      ++i;
    }
    return res;
  }

  Map<int, String> _columnsIndices() {
    final ind = <int, String>{};
    var i = 0;
    for (final col in columns) {
      ind[i] = col.name;
      ++i;
    }
    return ind;
  }

  /*Map<String, int> _columnsNamesWithIndices() {
    final ind = <String, int>{};
    var i = 0;
    for (final col in columns) {
      ind[col.name] = i;
      ++i;
    }
    return ind;
  }*/

  List<String> _columnsNames() {
    final str = <String>[];
    for (final column in columns) {
      str.add(column.name);
    }
    return str;
  }

  double _distance() {
    final columnIndice = _indiceForColumn(_geometryCol.name);
    var geoPoints = <GeoPoint>[];
    switch (_geometryCol.type) {
      case GeoPoint:
        geoPoints =
            _dataMatrix.typedRecordsForColumnIndice<GeoPoint>(columnIndice);
        break;
      case GeoSerie:
        final series =
            _dataMatrix.typedRecordsForColumnIndice<GeoSerie>(columnIndice);
        for (final serie in series) {
          geoPoints.addAll(serie.geoPoints);
        }
    }
    return geoPointsDistance(geoPoints);
  }

  Duration _duration() {
    assert(_timeCol != null);
    String sortCol;
    if (_isSortedBy != null) {
      sortCol = _isSortedBy;
    }
    _sort(_timeCol.name, inPlace: true);
    final tr = _timeRecords();
    final d = tr[tr.length - 1].difference(tr[0]);
    if (sortCol != null) {
      _sort(sortCol, inPlace: true);
    }
    return d;
  }

  List<GeoPoint> _geoPoints() {
    assert(geometryCol != null);
    assert(geometryCol.type == GeoPoint);
    return _dataMatrix.typedRecordsForColumnIndice<GeoPoint>(
        _indiceForColumn(_geometryCol.name));
  }

  double _maxSpeed({bool moving = false}) =>
      _speedCalc(moving: moving, max: true);

  double _avgSpeed({bool moving = false}) => _speedCalc(moving: moving);

  double _speedCalc({bool moving = false, bool max = false}) {
    assert(_speedCol != null);
    final data =
        _dataMatrix.recordsForColumnIndice(_indiceForColumn(_speedCol.name));
    switch (_dataMatrix.data.length) {
      case 0:
        return 0;
        break;
      case 1:
        if (moving) {
          final val = data[0] as double;
          if (val > 0) {
            return val;
          } else {
            return 0;
          }
        }
    }
    //print("SPEED DATA $data");
    final points = <double>[];
    for (final value in data) {
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

  int _indiceForColumn(String columnName) {
    int ind;
    var i = 0;
    for (final col in columns) {
      if (columnName == col.name) {
        ind = i;
        break;
      }
      ++i;
    }
    return ind;
  }

  Stream<Map<String, dynamic>> _iter() async* {
    var i = 0;
    final indices = _columnsIndices();
    while (i < numRows) {
      yield _dataMatrix.dataForIndex(i, indices);
      ++i;
    }
    //yield <String, dynamic>{"__endSignal__": true};
  }

  GeoDataFrame _sort(String columnName,
      {bool inPlace = false, bool reverse = false}) {
    assert(columnName != null);
    _isSortedBy = columnName;
    final colIndice = _indiceForColumn(columnName);
    final order = _sortIndexForIndice(colIndice);
    var _newMatrix = <List<dynamic>>[];
    for (final indice in order) {
      _newMatrix.add(_dataMatrix.data[indice]);
    }
    if (reverse) {
      _newMatrix = _newMatrix.reversed.toList();
    }
    if (!inPlace) {
      return GeoDataFrame._copyWithMatrix(this, _newMatrix);
    } else {
      _dataMatrix.data = _newMatrix;
    }
    return null;
  }

  List<int> _sortIndexForIndice(int indice) {
    final order = <int>[];
    final values = _columnDataWithIndex(indice);
    final orderedValues = values.keys.toList()..sort();
    for (final value in orderedValues) {
      order.add(values[value]);
    }
    return order;
  }

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
  }
}
