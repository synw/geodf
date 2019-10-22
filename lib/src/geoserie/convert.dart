//import 'package:ml_linalg/linalg.dart';
//import 'package:geopoint/geopoint.dart';
/*
/// Turn the numeric properties of a [GeoPoint] into a list of [Vector]
Map<String, Vector> geoPointsNumericPropertiesToVectors(
    List<GeoPoint> geoPoints) {
  final propValues = <String, List<double>>{};
  for (final point in geoPoints) {
    for (final prop in point.properties) {
      //print("PROPERTY ${prop.name} : ${prop.value}");
      double v;
      var propIsValid = false;
      switch (prop.type) {
        case double:
          v = double.tryParse(prop.value.toString()) ?? 0;
          propIsValid = true;
          break;
        case int:
          v = double.tryParse(prop.value.toString()) ?? 0;
          propIsValid = true;
          break;
        default:
      }
      if (propIsValid) {
        if (propValues.containsKey(prop.name)) {
          propValues[prop.name] = propValues[prop.name]..add(v);
        } else {
          propValues[prop.name] = <double>[v];
        }
      }
    }
  }
  print("PROP VALUES $propValues");

  final propertiesVectors = <String, Vector>{};
  propValues.forEach((k, v) {
    try {
      propertiesVectors[k] = Vector.fromList(v);
    } catch (e) {
      throw ("Can not encode property vector $k : $v $e");
    }
  });
  return propertiesVectors;
}*/
