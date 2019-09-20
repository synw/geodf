import "package:console/console.dart";
import '../dataframe/dataframe.dart';
import 'commands.dart';
import 'data_state.dart';

void geoReplPrompt(GeoDataFrame gdf) async {
  assert(gdf != null);
  df = gdf;
  Console.init();
  _prompt();
}

void _prompt() async {
  final cmdString = await readInput("> ");
  final cmd = readCmd(cmdString);
  await cmd.execute();
  _prompt();
}
