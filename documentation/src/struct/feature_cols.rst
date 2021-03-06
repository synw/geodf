Feature columns
---------------

There are special columns representing features. They are declared at dataframe
creation time. They are used internaly to make calculations and provide info in
computed properties or methods. Feature columns:

- geometry
   declares a geometry. Data types: `GeoPoint <https://pub.dev/documentation/geopoint/latest/geopoint/GeoPoint-class.html>`_
   or `GeoSerie <https://pub.dev/documentation/geopoint/latest/geopoint/GeoSerie-class.html>`_

- time
   the date column. Data type: ``DateTime``. Note: this column is
   created from timestamps

- speed
   the speed column: unit is meters per second.
   Data type: ``double``

Only the geometry column is required. The others are optional. Example:

.. highlight:: dart

::

   final data = <Map<String, dynamic>>[
      <String,dynamic>{
         "geometry": GeoPoint(latitude: 51.0, longitude: 0.0),
         "timestamp": 125855222,
         "speed": 0.0
      },
   ];
   final df = GeoDataFrame.fromRecords(data,
        geometryCol: "geometry",
        speedCol: "speed",
        timestampCol: "timestamp");

``featureCols``
"""""""""""""""

Get feature columns info:

::

   final fcols = df.featureCols();
   final timeCol = df.fcols.timeCol;

Shortcuts to get feature columns info:

::

   final timeCol = df.timeCol;
   final geomCol = df.geometryCol;
   final speedCol = df.speedCol;
   // internal type
   print(speedCol.dtype);
   // dart type
   print(speedCol.type);
