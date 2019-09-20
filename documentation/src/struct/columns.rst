
Columns
=======

A dataframe has columns. At minimum a geometry column.

The column object
-----------------

``GeoDataFrameColumn``
""""""""""""""""""""""

Properties:

:name: ``String``: the name of the column
:dtype: ``GeoDataFrameColumnType``: the internal type of the column:
        see the `types <types.html>`_ section for details
:type: ``Type``: the dart type the column's data
:indice: ``int``: the column indice for the data. Mostly for internal usage

Constructors
------------

``GeoDataFrameColumn.fromGeoJsonGeometry``
""""""""""""""""""""""""""""""""""""""""""

Build a column from parsed geojson objects

Positional parameters:

:geometry: ``dynamic``: a geojson geometry: either a `GeoJsonPoint <https://pub.dev/documentation/geojson/latest/geojson/GeoJsonPoint-class.html>`_
           , a `GeoJsonMultiPoint <https://pub.dev/documentation/geojson/latest/geojson/GeoJsonMultiPoint-class.html>`_
           or a `GeoJsonLine <https://pub.dev/documentation/geojson/latest/geojson/GeoJsonLine-class.html>`_
:columnName: ``String``: the name of the column

.. highlight:: dart

::

   final col = GeoDataFrameColumn.fromGeoJsonGeometry(someGeoJsonObject, "myline");
   print(col.dtype);
   print(col.type);

``GeoDataFrameColumn.inferFromDataPoint``
"""""""""""""""""""""""""""""""""""""""""

Build a column with types infered from a datapoint

Positional parameters:

:dataPoint: ``dynamic``: a sample of the data to check to infer types
:columnName: ``String``: the name of the column
