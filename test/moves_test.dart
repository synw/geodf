import "package:test/test.dart";
import 'package:geodf/geodf.dart';
import 'create_data.dart';

void main() {
  final df = GeoDataFrame.fromRecords(createDataWithStops(),
      geometryCol: "geopoint", speedCol: "speed", timestampCol: "date");

  test("moves", () async {
    expect(df.length, 100);
    //print("DATA ${df.data}");
    print("Zero speed: ${df.countZeros_("speed")}");
    final tls = await df.moves(minStopDuration: const Duration(seconds: 1));
    print(tls);
    expect(tls.numPoints > 0, true);
    expect(tls.sequences.length, 5);
  });
}
