Select
======

Records for column
------------------

``colRecords``
""""""""""""""

Select all the records for a column

Positional parameter:

:columnName: **required** ``String``: the name of the column to select from

.. highlight:: dart

::

   final List<GeoPoint> records = df.colRecords<GeoPoint>("geometry");

Limit
-----

``limit``
"""""""""

Limit the dataframe to a given number of rows

Positional parameter:

:max: ``int``: **required**: the max number of rows to return.

Named parameter:

:startIndex: ``int``: the index position to start select from. **Default**: 0

::

   final df = df.limit(50, startIndex: 20);
   // or
   df.limitI(50);

``limitI``
""""""""""

Same as for limit but in place

::

   df.limitI(50);
   print(df.numRows);
   // 50

Subset
------

``rowsSubset``
""""""""""""""

Select a rows subset

Positional parameter:

:startIndex: **required**: the index to start select from
:endIndex: **required**: the index to finish select from

.. highlight:: dart

::

   final List<List<dynamic>> rows = df.rowsSubset(10, 300);


``dataSubset``
""""""""""""""

Select a data subset

Positional parameter:

:startIndex: **required**: the index to start select from
:endIndex: **required**: the index to finish select from

::

   final List<Map<String, dynamic>> dataPoints = df.dataSubset(10, 300);

Features
--------

Directly select features

``timeRecords``
"""""""""""""""

Get a list of ``DateTime`` records from the time column

::

   final List<dynamic> records = df.timeRecords;

``geoPoints``
"""""""""""""

Get a list of `GeoPoint <https://pub.dev/documentation/geopoint/latest/geopoint/GeoPoint-class.html>`_
records from the time column. If the geometry columns's type is GeoPoint
it will return a list of the geopoints, if it is a `GeoSerie <https://pub.dev/documentation/geopoint/latest/geopoint/GeoSerie-class.html>`_
it will return a list of all the geopoints in all the geoseries

::

   final List<GeoPoint> records = df.geoPoints;

