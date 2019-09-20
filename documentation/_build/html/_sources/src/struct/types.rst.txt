Types
=====

``GeoDataFrameColumnType``
""""""""""""""""""""""""""

Represents the internal type of a column:

- categorical
    A ``String`` for data representing categorical information

- numeric
    Either a ``double`` of an ``int``

- time
    A ``DateTime`` object

- geometry
    `GeoPoint <https://pub.dev/documentation/geopoint/latest/geopoint/GeoPoint-class.html>`_
    or `GeoSerie <https://pub.dev/documentation/geopoint/latest/geopoint/GeoSerie-class.html>`_

``TimelineSequenceType``
""""""""""""""""""""""""

Represents the type of a timeline sequence

- moving
    The sequence is a moving sequence with a speed value

- stopped
    Geographicaly static sequence

- unknown
    Not set

``TimestampType``
""""""""""""""""""""""""

The time unit of a timestamp

- seconds
    Seconds since epoch

- milliseconds
    Milliseconds since epoch

- microseconds
    Microseconds since epoch
