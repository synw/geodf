import 'package:ml_linalg/linalg.dart';

List<double> sliceAndNormMm<T>(List<T> values, {int size = 10}) {
  assert(T is int || T is double);
  final vector = Vector.fromList(meanSlices(values, size: size));
  return vector.rescale().toList();
}

List<double> meanSlices<T>(List<T> values, {int size = 10}) {
  assert(T is int || T is double);
  var isInt = false;
  if (T is int) {
    isInt = true;
  }
  final slices = <List<double>>[];
  final sliceSize = values.length ~/ size;
  var currentSlice = <double>[];
  values.forEach((v) {
    if (currentSlice.length < sliceSize) {
      if (isInt) {
        currentSlice.add(double.parse("$v"));
      } else {
        currentSlice.add(v as double);
      }
    } else {
      slices.add(currentSlice);
      currentSlice = <double>[];
    }
  });
  final res = <double>[];
  for (final slice in slices) {
    final vector = Vector.fromList(slice);
    final m = vector.mean();
    res.add(m);
  }
  return res;
}
