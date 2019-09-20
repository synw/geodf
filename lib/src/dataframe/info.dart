import 'package:meta/meta.dart';
import 'column.dart';

class GeoDataFrameInfo {
  void head({
    @required int lines,
    @required List<String> columnsNames,
    @required List<List<dynamic>> data,
  }) {
    print(columnsNames.join(","));
    final rows = data.sublist(0, lines);
    printRows(rows);
  }

  void printRows(List<dynamic> rows) {
    for (final row in rows) {
      print(row.join(","));
    }
  }

  void cols(
      {@required List<GeoDataFrameColumn> columns,
      @required GeoDataFrameFeatureColumns featureColumns}) {
    final specificCols = <String, GeoDataFrameColumn>{};
    final otherCols = <GeoDataFrameColumn>[];
    for (final col in columns) {
      if (col == featureColumns.time) {
        specificCols["time"] = col;
      } else if (col == featureColumns.geometry) {
        specificCols["geometry"] = col;
      } else if (col == featureColumns.speed) {
        specificCols["speed"] = col;
      } else {
        otherCols.add(col);
      }
    }
    // print
    print("* Geometry column: ${specificCols["geometry"]}");
    print("* Time column: ${specificCols["time"]}");
    print("* Speed column: ${specificCols["speed"]}");
    for (final col in otherCols) {
      print("Column $col");
    }
  }
}
