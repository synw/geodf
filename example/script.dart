import 'package:geodf/geodf.dart';
import 'package:geopoint/geopoint.dart';

void main(List<String> args) async {
  final df = await GeoDataFrame.fromGeoJsonFile("data/positions_sample.geojson",
      timestampFormat: TimestampType.seconds, verbose: true);
  df.cols();
  df.headCol("speed");
}
