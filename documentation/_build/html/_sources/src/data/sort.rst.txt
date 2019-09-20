Sort
====

``sort``
""""""""

Ascendant sort the dataframe from a column name

Positional parameter:

:columnName: **required** ``String``: the name of the column to sort

.. highlight:: dart

::

   final df2 = df.sort("timestamp");

``sortI``
"""""""""

Same as sort but in place:

::

   df.sortI("speed");

``sortDesc``
""""""""""""

Descendant sort the dataframe from a column name

Positional parameter:

:columnName: **required** ``String``: the name of the column to sort


::

   final df2 = df.sortDesc("timestamp");

``sortDescI``
"""""""""""""

Same as sortDesc but in place:

::

   df.sortDescI("speed");
