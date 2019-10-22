import 'package:geopoint/geopoint.dart';
import 'package:geodesy/geodesy.dart';

final _geodesy = Geodesy();

double geoPointsDistance(List<GeoPoint> geoPoints) {
  var dist = 0.0;
  var prevPoint = geoPoints[0];
  var i = 0;
  for (final geoPoint in geoPoints) {
    if (i == 0) {
      ++i;
      continue;
    }
    dist += _geodesy.distanceBetweenTwoGeoPoints(
        prevPoint.toLatLng(), geoPoint.toLatLng());
    prevPoint = geoPoint;
    ++i;
  }
  return dist;
}
