Repl
====

Interactive shell to explore, clean and transform a dataframe

.. highlight:: dart

::

   import 'package:geodf/geodf.dart';

   void main(List<String> args) async {
     final df = GeoDataFrame.random();
     geoReplPrompt(df);
   }

Or from geojson:

::

   import 'package:geodf/geodf.dart';

   void main(List<String> args) async {
     final df = await GeoDataFrame.fromGeoJsonFile("data/positions.geojson",
         timestampFormat: TimestampType.seconds, verbose: true);
     geoReplPrompt(df);
   }

Commands:

:backup: backup the dataframe
:restore: restore the dataframe from a previous backup
:exit: exit the repl

Info
----

:head: show dataframe's first records. Parameter: ``int``
       number of rows to show
:show: show dataframe's first records with some info.
       Parameter: ``int`` number of rows to show
:cols: show columns information

Properties
----------

:speed: the total speed
:mspeed: the total speed when in movement

Count
-----

:count: count the number of rows
:nulls: count the number of null for a column.
        Parameter **required** ``String`` column name
:zeros: count the number of zeros for a column.
        Parameter **required** ``String`` column name

Transform
---------

:limit: limit the dataframe to a number of rows
        Parameter **required** ``int`` the number of rows to keep
:sort: sort the dataframe by a column
       Parameter **required** ``String`` column name

Sequences
---------

:moves: experimental movements sequence detection
:ts: experimental time gap separated timeseries sequence detection



