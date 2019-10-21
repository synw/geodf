import 'package:geopoint/geopoint.dart';

List<Map<String, dynamic>> createDataWithStops() {
  final dataset = <Map<String, dynamic>>[];
  var row = _Row(
      geoPoint: GeoPoint(latitude: 0.0, longitude: 0.0),
      speed: 30.0,
      altitude: 300.0,
      date: DateTime.now().subtract(Duration(hours: 1)));
  var i = 0;
  while (i < 100) {
    var stop = false;
    if (<int>[30, 31, 32, 60, 61, 62].contains(i)) {
      stop = true;
    }
    final currentRow = _Row.fromPrevious(row, stop: stop);
    dataset.add(currentRow.toJson());
    row = currentRow;
    ++i;
  }
  return dataset;
}

class _Row {
  _Row({this.geoPoint, this.speed, this.altitude, this.date});

  final GeoPoint geoPoint;
  final double speed;
  final double altitude;
  DateTime date;

  _Row.fromPrevious(_Row prevRow, {bool stop = false})
      : geoPoint = prevRow.geoPoint,
        speed = (stop) ? 0.0 : 30.0,
        altitude = prevRow.altitude {
    final newDate = prevRow.date.add(Duration(seconds: 5));
    date = DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "geopoint": geoPoint,
      "speed": speed,
      "altitude": altitude,
      "date": date
    };
  }
}
