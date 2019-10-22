import 'package:geodf/geodf.dart';

void main(List<String> args) async {
  await GeoDataFrame.fromGeoJsonFile("data/positions_sample.geojson",
      timestampFormat: TimestampType.seconds, verbose: true)
    ..cols()
    ..headCol("speed");
}
