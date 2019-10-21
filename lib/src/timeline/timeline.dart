import 'package:meta/meta.dart';
import '../types.dart';

class TimelineScene {
  TimelineScene({this.sequences});

  List<TimelineSequence> sequences;

  int get numPoints =>
      sequences.fold<int>(0, (curr, next) => curr + next.length);

  List<String> sequencesStr() {
    final norm = <double>[];
    final seq = <String>[];
    for (final sequence in sequences) {
      final p = (sequence.length * 100) / numPoints;
      norm.add(p);
    }
    var i = 0;
    for (final sequence in sequences) {
      final d = sequence.toStringFromPercent(
          percent: "${norm[i].toStringAsFixed(0)}");
      seq.add("${_percentBarFromNorm(norm[i])} $d");
      ++i;
    }
    return seq;
  }

  void normalizeSequences() {
    final seq = <TimelineSequence>[];
    for (final sequence in sequences) {
      final p = (sequence.length * 100) / numPoints;
      sequence.percentOfScene = p;
      seq.add(sequence);
    }
    sequences = seq;
  }

  void printSequences() => sequencesStr().forEach((seq) => print);

  @override
  String toString() {
    return sequences.join(", ");
  }
}

String _percentBarFromNorm(double normNum) {
  final totalBars = 10;
  final bar = "|";
  var val = (normNum.toInt() / 10);
  if (val > totalBars) {
    val = totalBars.toDouble();
  }
  var res = "";
  var i = 1;
  while (i < totalBars) {
    if (val >= i) {
      res += bar;
    } else {
      res += " ";
    }
    ++i;
  }
  return res;
}

class TimelineSequence {
  TimelineSequence(
      {@required this.timeColName,
      this.type = TimelineSequenceType.unknown,
      this.startIndex = 0,
      this.endIndex = 0});

  TimelineSequenceType type;
  String timeColName;
  int startIndex;
  int endIndex;
  double percentOfScene;

  var data = <Map<String, dynamic>>[];

  bool get isEmpty => (endIndex - startIndex) == 0;

  int get length => (endIndex - startIndex);

  DateTime get startDate => _startDate();

  DateTime get endDate => _endDate();

  Duration get duration => _endDate().difference(_startDate());

  String get durationFormated => formatDuration(duration);

  TimelineSequence.empty();

  DateTime _startDate() {
    if (data.isEmpty) {
      return null;
    }
    DateTime dt;
    try {
      dt = data[0][timeColName] as DateTime;
    } catch (e) {
      throw ("Can not find start date $e");
    }
    return dt;
  }

  DateTime _endDate() {
    if (data.isEmpty) {
      return null;
    }
    DateTime dt;
    try {
      dt = data[data.length - 1][timeColName] as DateTime;
    } catch (e) {
      throw ("Can not find end date $e");
    }
    return dt;
  }

  String toTypeStr() {
    String str;
    switch (type) {
      case TimelineSequenceType.moving:
        str = ">> Moving";
        break;
      default:
        str = "Stop";
    }
    return str;
  }

  @override
  String toString() {
    final t = _typeToString();
    return "$t $startIndex $endIndex";
  }

  String _typeToString() {
    String s;
    switch (type) {
      case TimelineSequenceType.moving:
        s = "Moving";
        break;
      case TimelineSequenceType.stopped:
        s = "Stop";
        break;
      default:
        s = "Unknown";
    }
    return s;
  }

  String toStringFromPercent({String percent = ""}) {
    var l = "";
    if (data.isNotEmpty) {
      l = "${data.length} rows";
    }
    var std = "$percent";
    if ((startDate != null) && (endDate != null)) {
      std = " from $startDate to $endDate (${formatDuration(duration)})";
    }
    var t = "";
    if (type != TimelineSequenceType.unknown) {
      t = toTypeStr() + ": ";
    }
    return "$t${l}$std";
  }
}

String formatDuration(Duration duration) {
  var str = "0";
  if (duration.inDays > 0) {
    str = "${duration.inDays} days";
  } else if (duration.inHours > 0) {
    str = "${duration.inHours} hours";
  } else if (duration.inMinutes > 0) {
    str = "${duration.inMinutes} minutes";
  } else if (duration.inSeconds > 0) {
    str = "${duration.inSeconds} seconds";
  } else if (duration.inMilliseconds > 0) {
    str = "${duration.inMilliseconds} milliseconds";
  } else if (duration.inMicroseconds > 0) {
    str = "${duration.inMicroseconds} microseconds";
  }
  return str;
}
