import 'package:geodf/geodf.dart';

Future<void> main(List<String> args) async {
  final df = await GeoDataFrame.fromGeoJsonFile("data/positions_sample.geojson",
      timestampFormat: TimestampType.seconds, verbose: true)
    ..show();
}
