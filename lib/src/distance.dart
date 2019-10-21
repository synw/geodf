double kmRoundedFromMeters(double distanceMeters) {
  String d;
  final raw = distanceMeters / 1000;
  switch (raw > 9.9) {
    case true:
      d = raw.toStringAsFixed(0);
      break;
    default:
      d = raw.toStringAsFixed(1);
  }
  return double.parse(d);
}
