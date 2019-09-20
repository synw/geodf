Introduction
============

This library provides a ``GeoDataFrame`` object to manipulate geographical
series, with a time dimension or not.

The dataframe behaves like the `pandas <https://pandas.pydata.org/>`_ ones
in python. In addition the geodf dataframes have
`feature columns <struct/feature_cols.html>`_: columns that the function
and units are know: geometry, time, speed. This make it possible for the
dataframe to provide more information out of the box from these columns.
