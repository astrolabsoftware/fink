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

where `conf/fink.conf.tutorial3` is a copy of `conf/fink.conf` updated with your configuration.

## Applying quality cuts

To define quality cuts, follow the [Tutorial 2](bogus_filtering.md). We recap the main steps here:

- Create a filter in `$FINK_HOME/userfilters/levelone.py`
- Register the filter.

Do not forget to have the HBase service running.

## Processing data from the raw database

## Create a processor in levelone.py

## Register the processor

## Building the science database
