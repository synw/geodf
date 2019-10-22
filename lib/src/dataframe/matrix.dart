import 'package:ml_linalg/vector.dart';

import '../exceptions.dart';

class GeoDataMatrix {
  List<List<dynamic>> data = <List<dynamic>>[];

  void add(List<dynamic> v) => data.add(v);

  List<dynamic> recordsForColumnIndice(int columnIndice, {int limit}) {
    final dataFound = <dynamic>[];
    var i = 0;
    for (final row in data) {
      dataFound.add(row[columnIndice]);
      ++i;
      if (limit != null) {
        if (i >= limit) {
          break;
        }
      }
    }
    return dataFound;
  }

  List<T> typedRecordsForColumnIndice<T>(int columnIndice,
      {int limit, bool ignoreNulls = false}) {
    final dataFound = <T>[];
    var i = 0;
    for (final row in data) {
      if (ignoreNulls) {
        if (row[columnIndice] == null) {
          dataFound.add(null);
        }
      }
      T val;
      try {
        val = row[columnIndice] as T;
      } catch (e) {
        throw TypeConversionError("Can not convert record $val to type $T $e");
      }
      dataFound.add(val);
      ++i;
      if (limit != null) {
        if (i >= limit) {
          break;
        }
      }
    }
    return dataFound;
  }

  int countForValues(int columnIndice, List<dynamic> values) {
    var n = 0;
    data.forEach((row) {
      if (values.contains(row[columnIndice])) {
        ++n;
      }
    });
    return n;
  }

  List<Map<String, dynamic>> dataForIndexRange(
      int startIndex, int endIndex, Map<int, String> indices) {
    final dataRows = <Map<String, dynamic>>[];
    for (final row in data.sublist(startIndex, endIndex)) {
      final dataRow = <String, dynamic>{};
      var i = 0;
      row.forEach((dynamic item) {
        dataRow[indices[i]] = item;
        ++i;
      });
      dataRows.add(dataRow);
    }
    return dataRows;
  }

  List<List<dynamic>> rowsForIndexRange(int startIndex, int endIndex) {
    final rows = <List<dynamic>>[];
    data.sublist(startIndex, endIndex).forEach(rows.add);
    return rows;
  }

  Map<String, dynamic> dataForIndex(int index, Map<int, String> indices) {
    final row = <String, dynamic>{};
    final dataRow = data[index];
    var i = 0;
    dataRow.forEach((dynamic item) {
      row[indices[i]] = item;
      ++i;
    });
    return row;
  }

  double sumDoubleCol(int columnIndice) {
    final data = typedRecordsForColumnIndice<double>(columnIndice);
    final vector = Vector.fromList(data);
    return vector.sum();
  }

  double meanDoubleCol(int columnIndice) {
    final data = typedRecordsForColumnIndice<double>(columnIndice);
    final vector = Vector.fromList(data);
    return vector.mean();
  }
}
