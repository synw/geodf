Create
======

From a list of dictionnaries
----------------------------

Create a dataframe from a list of dictionnaries

 ``GeoDataFrame.fromRecords``

Named parameters:

:geometryCol: **required** ``String``: the geometry column name. The data must be
                           of type `GeoPoint
                           <https://pub.dev/documentation/geopoint/latest/geopoint/GeoPoint-class.html>`_
                           or `GeoSerie
                           <https://pub.dev/documentation/geopoint/latest/geopoint/GeoSerie-class.html>`_
:speedCol: ``String``: the speed column name. The data must be
                           of type ``double``
:timestampCol: ``String``: the timestamp column name. The data must be
                           of type ``int``
:timestampFormat: ``TimestampType``: the type of
                  timestamp **default** ``TimestampType.milliseconds``
:verbose: ``bool``: verbosity **default** ``false``

.. highlight:: dart

::

   final data = <Map<String, dynamic>>[
      <String,dynamic>{
         "geometry": GeoPoint(latitude: 51.0, longitude: 0.0),
         "timestamp": 125855222,
         "speed": 0.0,
         "altitude": 100.0,
         "foo": 30,
         "bar": 10.0
      },
   ];
   final df = GeoDataFrame.fromRecords(data,
        geometryCol: "geometry",
        speedCol: "speed",
        timestampCol: "timestamp");

From a geojson file
-------------------

Create a dataframe from a geojson file

**Important**: supported geojson features are: Point, Line, MultiPoint

 ``GeoDataFrame.fromGeoJsonFile``

Parameters:

:path: **required** ``String``: the path to the geojson file

Named parameters:

:timestampProperty: ``String``: the geojson property with a
                    timestamp **default**: ``timestamp``
:speedProperty: ``String``: the geojson property for speed **default**: ``speed``
:timestampFormat: ``TimestampType``: the type of the timestamp
                  **default**: ``TimestampType.milliseconds``
:verbose: ``bool``: verbosity **default** ``false``

::

   final df = await GeoDataFrame.fromGeoJsonFile("data/positions.geojson");

With random data
----------------

Create a dataframe filled with random data

``GeoDataFrame.random``

Named parameters:

:distance: ``double``: the distance between points **default** ``10.0``
:speed: ``double`` speed of each point. If not provided it will be randomized
:timeInterval: *Duration* time between each point **default**
               ``Duration(seconds: 10)``
:bearing: ``double`` bearing of each point **default** ``142.0``
:startLatitude: ``double`` latitude of the first geopoint **default** ``51.0``
:startLongitude: ``double`` longitude of the first geopoint **default** ``0.0``
:numRecords: ``int`` number of records **default** ``100``
:verbose: ``bool``: verbosity **default** ``false``

::

   final df = GeoDataFrame.random();
