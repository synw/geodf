import 'dart:io';
import 'models.dart';
import 'data_state.dart';

GeoReplCmd readCmd(String cmdString) {
  final l = cmdString.split(" ");
  final cmdName = l[0];
  var args = <String>[];
  if (l.length > 1) {
    args = l.sublist(1, l.length);
  }
  return _cmdFromName(cmdName, args);
}

GeoReplCmd _cmdFromName(String cmdString, List<String> args) {
  GeoReplCmd cmd;
  if (df.columnsNames.contains(cmdString)) {
    final nargs = <String>[cmdString];
    if (args.isNotEmpty) {
      nargs.add(args[0]);
    }
    cmd = _head(nargs);
  } else {
    switch (cmdString) {
      case "head":
        cmd = _head(args);
        break;
      case "show":
        cmd = _show(args);
        break;
      case "exit":
        cmd = _exit();
        break;
      case "cols":
        cmd = _cols();
        break;
      case "backup":
        cmd = _backup();
        break;
      case "restore":
        cmd = _restore();
        break;
      case "count":
        cmd = _count();
        break;
      case "speed":
        cmd = _speed();
        break;
      case "mspeed":
        cmd = _movingSpeed();
        break;
      case "moves":
        cmd = _moves();
        break;
      case "sort":
        cmd = _sort(args);
        break;
      case "nulls":
        cmd = _nulls(args);
        break;
      case "zeros":
        cmd = _zeros(args);
        break;
      case "ts":
        cmd = _ts(args);
        break;
      case "limit":
        cmd = _limit(args);
        break;
      default:
        cmd = GeoReplCmd.unknown(cmdString);
    }
  }
  return cmd;
}

GeoReplCmd _show(List<String> args) {
  return GeoReplCmd(
      name: "show",
      helpText: "Shows informations about the dataframe",
      execute: () async => df.show());
}

GeoReplCmd _head(List<String> args) {
  return GeoReplCmd(
      name: "head",
      helpText: "Shows the first records of the dataframe or a column",
      execute: () async {
        if (args.isEmpty) {
          df.head();
        } else {
          if (args.length > 1) {
            df.headCol(args[0], lines: int.parse(args[1]));
          } else {
            df.headCol(args[0]);
          }
        }
      });
}

GeoReplCmd _count() {
  return GeoReplCmd(
      name: "count",
      helpText: "Counts the number of rows of the dataframe",
      execute: () async => print("${df.numRows} rows"));
}

GeoReplCmd _exit() {
  return GeoReplCmd(
      name: "exit", helpText: "Exit the program", execute: () async => exit(0));
}

GeoReplCmd _cols() {
  return GeoReplCmd(
      name: "info",
      helpText: "Gives info about columns",
      execute: () async => df.cols());
}

GeoReplCmd _sort(List<String> args) {
  assert(args.length == 1);
  return GeoReplCmd(
      name: "sort",
      helpText: "Sort the dataframe from a column name",
      execute: () async {
        df.sortI(args[0]);
        print("Dataframe sorted with column ${args[0]}");
      });
}

GeoReplCmd _nulls(List<String> args) {
  assert(args.length == 1);
  return GeoReplCmd(
      name: "nulls",
      helpText: "Count nulls for a column",
      execute: () async {
        final n = df.countNulls(args[0]);
        final percent = (n * 100) / df.numRows;
        final p = percent.toStringAsFixed(1);
        print("$n nulls in column ${args[0]} ($p% of ${df.numRows} records)");
      });
}

GeoReplCmd _zeros(List<String> args) {
  assert(args.length == 1);
  return GeoReplCmd(
      name: "zeros",
      helpText: "Count zero values for a column",
      execute: () async {
        final n = df.countZeros(args[0]);
        final percent = (n * 100) / df.numRows;
        final p = percent.toStringAsFixed(1);
        print("$n zeros in column ${args[0]} ($p% of ${df.numRows} records)");
      });
}

GeoReplCmd _backup() {
  return GeoReplCmd(
      name: "backup",
      helpText: "Backup the dataframe",
      execute: () async {
        df.backupI();
        print("Dataframe backed up");
      });
}

GeoReplCmd _restore() {
  return GeoReplCmd(
      name: "restore",
      helpText: "Restore the dataframe",
      execute: () async {
        df.restoreI();
        print("Dataframe restored (${df.numRows} rows)");
      });
}

GeoReplCmd _speed() {
  return GeoReplCmd(
      name: "speed",
      helpText: "Average speed of the geometry column",
      execute: () async => print("Average speed: ${df.avgSpeed}"));
}

GeoReplCmd _movingSpeed() {
  return GeoReplCmd(
      name: "moving_speed",
      helpText: "Average speed of the geometry column only when moving",
      execute: () async =>
          print("Average speed when moving: ${df.avgSpeedWhenMoving}"));
}

GeoReplCmd _moves() {
  return GeoReplCmd(
      name: "mseq",
      helpText: "Moving sequences",
      execute: () async {
        final scene = await df.moves();
        //print(scene.sequences.length);
        /*for (final seq in scene.sequences) {
          print(
              "${seq.rows.length} rows : ${seq.startIndice}/${seq.endIndex}");
        }*/
        scene.printSequences();
      });
}

GeoReplCmd _ts(List<String> args) {
  assert(args.length == 1);
  return GeoReplCmd(
      name: "ts",
      helpText: "Split the dataframe in time sequences",
      execute: () async {
        final durationUnit =
            args[0].substring(args[0].length - 1, args[0].length);
        final value = int.parse(args[0].substring(0, (args[0].length - 1)));
        Duration dur;
        switch (durationUnit) {
          case "d":
            dur = Duration(days: value);
            break;
          case "h":
            dur = Duration(hours: value);
            break;
          case "m":
            dur = Duration(minutes: value);
            break;
          case "s":
            dur = Duration(seconds: value);
            break;
          default:
            throw ("Unknown duration unit $durationUnit");
        }
        await df.timeSequences(gap: dur)
          ..printSequences();
      });
}

GeoReplCmd _limit(List<String> args) {
  assert(args.length == 1);
  return GeoReplCmd(
      name: "limit",
      helpText: "Limit the dataframe to a number of rows",
      execute: () async {
        final limit = int.parse(args[0]);
        df.limitI(limit);
        print("Dataframe limited to $limit rows");
      });
}
