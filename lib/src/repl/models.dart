import 'package:meta/meta.dart';

class GeoReplCmd {
  GeoReplCmd(
      {@required this.name, @required this.helpText, @required this.execute});

  final String name;
  final String helpText;
  final Function execute;

  GeoReplCmd.unknown(String name)
      : name = "Unknown command $name",
        helpText = "",
        execute = _unknownCmd;

  static void _unknownCmd() => print("Unknown command");
}
