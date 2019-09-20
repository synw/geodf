Count
=====

All rows
--------

.. highlight:: dart

::

   int n = df.numRows;

Nulls
-----

``countNulls``
""""""""""""""

Count the null values in a column.

Positional parameter:

:columnName: **required** ``String``: the name of the column to count nulls in

Named parameter:

:nullValues: ``List<dynamic>``: list of values considered. **Default**:
             ``[null, "null", "nan", "NULL", "N/A"]``

::

   final int nulls = df.countNulls("speed", nullValues= <dynamic>[null]);

Zeros
-----

``countZeros``
""""""""""""""

Count zeros in a column

Positional parameter:

:columnName: **required** ``String``: the name of the column to count nulls in

Named parameter:

:zeroValues: ``List<dynamic>``: list of values considered. **Default**:
             ``[0]``

::

   final int zeros = df.countZeros("speed", zeroValues= <dynamic>[0,"0"]);
