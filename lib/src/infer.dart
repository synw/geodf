import 'package:geopoint/geopoint.dart';

Type inferGeometryType(dynamic geom) {
  Type t;
  if (geom is GeoPoint) {
    t = GeoPoint;
  } else if (geom is GeoSerie) {
    t = GeoSerie;
  } else {
    throw ("Unknown geometry type ${geom.runtimeType}");
  }
  return t;
}
