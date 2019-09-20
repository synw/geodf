Info
====

Dataframe
---------

``head``
""""""""

Display the first rows and some info about the dataframe

Positional parameter:

:lines: ``int``: the number of rows to display. **Default**: 5

.. highlight:: dart

::

   df.head();

``show``
""""""""

Same as head but a little more info is displayed

::

   df.show();

Columns
-------

``cols``
""""""""

Display info about columns

Positional parameter:

:columnName: **required** ``String``: the name of the column to show
:lines: ``int``: the number of rows to display. **Default**: 5

.. highlight:: dart

::

   df.cols();

``columnNames``
"""""""""""""""

Returns a list of column names

Positional parameter:

:lines: ``int``: the number of rows to display. **Default**: 5

::

   df.columnNames();
