# Geodf

Geospatial timeseries analysis. Provides a `GeoDataFrame` object. Features

- Explore, clean and transform geographical data
- Interactive shell

Check the [documentation](https://geodf.readthedocs.io/en/latest/) for usage.

## Repl

An interactive shell is available to manipulate a dataframe. Example session:

```
Loading geojson file data/positions_sample.geojson
Processing geojson features
Loaded 942 geojson features
> cols
* Geometry column: geometry (GeoDataFrameColumnType.geometry) with GeoPoint data
* Time column: timestamp (GeoDataFrameColumnType.time) with DateTime data
* Speed column: speed (GeoDataFrameColumnType.numeric) with double data
Column id (GeoDataFrameColumnType.numeric) with int data
Column device_id (GeoDataFrameColumnType.numeric) with int data
Column latitude (GeoDataFrameColumnType.numeric) with double data
Column longitude (GeoDataFrameColumnType.numeric) with double data
Column altitude (GeoDataFrameColumnType.numeric) with double data
Column course (GeoDataFrameColumnType.numeric) with double data
Column battery_level (GeoDataFrameColumnType.numeric) with double data
Column distance (GeoDataFrameColumnType.numeric) with double data
Column total_distance (GeoDataFrameColumnType.numeric) with double data
Column accuracy (GeoDataFrameColumnType.numeric) with double data
Column device_name (GeoDataFrameColumnType.categorical) with String data
Column is_motion (GeoDataFrameColumnType.numeric) with int data
> timestamp
Column timestamp (942 records of type DateTime):
2019-04-14 16:24:48.000,2019-04-14 16:25:40.000,2019-04-14 16:26:48.000,2019-04-14 16:27:48.000,2019-04-14 16:28:48.000,2019-08-12 12:19:39.000,2019-08-12 12:32:19.000,2019-08-12 12:33:21.000,2019-08-12 12:33:49.000,2019-08-12 12:40:23.000
> speed
Column speed (942 records of type double):
0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0
> zeros speed
241 zeros in column speed (25.6% of 942 records)
> nulls timestamp
0 nulls in column timestamp (0.0% of 942 records)
> battery_level
Column battery_level (942 records of type double):
65.0,65.0,64.0,64.0,64.0,95.0,94.0,93.0,93.0,93.0
> backup
Dataframe backed up
> limit 10
Dataframe limited to 10 rows
> count
10 rows
> restore
Dataframe restored (942 rows)
> exit
```
