import 'package:geodf/geodf.dart';

void main(List<String> args) async {
  final df = await GeoDataFrame.fromGeoJsonFile("data/positions_sample.geojson",
      timestampFormat: TimestampType.seconds, verbose: true);
  geoReplPrompt(df);
}
