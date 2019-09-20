Vocabulary
==========

These conventions are used in methods and properties name

Data point
----------

A data point is a ``Map<String, dynamic>`` dictionnary with column names
and data values, a line in the dataframe with qualified column names

.. highlight:: dart

::

   final List<Map<String, dynamic>> dataPoints = df.dataSubset(10, 300);

Row
---

A row is a ``List<dynamic>`` list of records, a line in the dataframe:

::

   final List<List<dynamic>> rows = df.rowsSubset(10, 300);


Record
------

A record is a single value: ex:

::

   final List<GeoPoint> records = df.colRecords<GeoPoint>("geometry");

Index
-----

A row index list of ``int``: the vertical dimension of the dataframe

Indice
------

A column indice list of ``int``: the horizontal dimension of the dataframe
