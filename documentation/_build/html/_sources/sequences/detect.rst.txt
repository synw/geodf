Sequences detection
===================

Moves
-----

``moves``
"""""""""

Get a TimelineScene with moving sequences and stopped sequences. This is
based on the speed column

.. highlight:: dart

::

   final TimelineScene scene = df.moves();

Timeseries
----------

``timeSequences``
"""""""""""""""""

Get a TimelineScene with sequences splited from a time interval

Positional parameter:

:lines: ``Duration`` **required**: the time gap between sequences to use

.. highlight:: dart

::

   final TimelineScene scene = df.timeSequences(gap: Duration(minutes:5);
