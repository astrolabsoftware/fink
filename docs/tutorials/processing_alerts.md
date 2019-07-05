# Tutorial: Processing alerts

**Context**

This tutorial illustrates the basics of connecting to the raw database (Parquet), filtering out alerts that do not satisfy quality criteria, and processing alerts before pushing them to the science database (HBase).

**Before starting**

For this tutorial, make sure:

* Fink is installed on your computer.
* Apache Spark (2.4+) is installed on your computer.
* Docker is installed on your computer.
* HBase is installed on your computer.

See [Getting started](../index.md) for more information.

## Building the raw database

To build the raw database, follow the [Tutorial 1](raw_db.md). We recap the main steps here:

```bash
# Connect the alert system to the raw database
fink start stream2raw -c conf/fink.conf.tutorial3 --simulator

# Send stream of data
fink start simulator
```

where `conf/fink.conf.tutorial3` is a copy of `conf/fink.conf` with the following change:

```diff
# The name of the HBase table
-SCIENCE_DB_NAME="test_catalog"
+SCIENCE_DB_NAME="test_catalog_xmatch"

# Total number of alerts to send
-POOLSIZE=100
+POOLSIZE=489
```

## Applying quality cuts

To define quality cuts, follow the [Tutorial 2](bogus_filtering.md). We recap the main steps here:

- Create a filter in `$FINK_HOME/userfilters/levelone.py`
- Register the filter.

Do not forget to have the HBase service running.

## Processing data from the raw database

Once the raw database is initialised (i.e. contains at least one alert) and hbase started, you can stream data from it and apply filters and data processors. We focus here only on the processing part. Processors to be applied to the data can be found under `${FINK_HOME}/userfilters/levelone.py`. We provide a default processor for reference, but you can edit it or add more if wanted. The procedure for adding processors is the following:

## Create a processor in levelone.py

The skeleton of a filter is always the same:

```python
@pandas_udf(AnyDataType(), PandasUDFType.SCALAR)
def my_great_processor_name(colname1: Any, colname2: Any, ...) -> pd.Series:
  """ The documentation
  """
  # Your logic based on the input columns
  column_to_return_based_on_inputs = ...

  return pd.Series(column_to_return_based_on_inputs)
```

`${FINK_HOME}/userfilters/levelone.py` contains an example of processor performing a cross-match between alert data and the catalogs at CDS Strasbourg.

## Register the processor

At the top of `${FINK_HOME}/userfilters/levelone.py`, you need to pass the name of your processor such that it gets applied to the data the next time you launch `fink start raw2science`:

```python
# Disable filters for this example
filter_levelone_names = []

# Declare here the processors that will be applied in the
# level one (stream -> raw database)
processor_levelone_names = ["my_great_processor_name"]
```

Et voilà! as simple as it.

## Building the science database

To see the filters in action, execute the raw2science service:

```bash
fink start raw2science -c conf/fink.conf.tutorial3

# Send stream of data
fink start simulator
```

You can check that the table has been updated with new alerts by using the HBase shell for example:

```hbase
# hbase shell
hbase(main):001:0> list
TABLE
test_catalog_xmatch
1 row(s)
Took 0.3936 seconds
=> ["test_catalog_xmatch"]
hbase(main):002:0> count "test_catalog_xmatch"
489 row(s)
Took 0.1316 seconds
=> 489
```

Alternatively, you can also use Apache Spark to explore the science database:

```python
# Launch pyspark shell with fink_shell
from fink_broker.sparkUtils import init_sparksession
import json

spark = init_sparksession(
    name="readingScienceDB", shuffle_partitions=2, log_level="ERROR")

# Open the catalog that describes the HBase table
with open('catalog.json') as f:
    catalog = json.load(f)

catalog_dic = json.loads(catalog)

# Create a Spark DataFrame with the science DB data in it.
df = spark.read.option("catalog", catalog)\
    .format("org.apache.spark.sql.execution.datasources.hbase")\
    .load()

print("Number of entries in {}: ".format(
  catalog_dic["table"]["name"]), df.count())
# Number of entries in test_catalog:  489

# Match statistics
df.groupBy("cross_match_alerts_per_batch").count().show()
# +----------------------------+-----+
# |cross_match_alerts_per_batch|count|
# +----------------------------+-----+
# |                       RRLyr|   61|
# |                     EB*WUMa|   16|
# |                  PulsV*WVir|    1|
# |                        Blue|    1|
# |               Candidate_EB*|    1|
# |                         QSO|    2|
# |                       AMHer|    1|
# |                     Unknown|  369|
# |                         HB*|    4|
# |                   Seyfert_1|    3|
# |                   EB*betLyr|    1|
# |                         AGN|    1|
# |                        Star|   25|
# |                       BLLac|    2|
# |               AGN_Candidate|    1|
# +----------------------------+-----+
```
