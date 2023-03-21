![Screenshot](../img/fink-filters.png)


# Create your filter for Fink

This tutorial goes step-by-step for creating a filters used to define which information will be sent to you by the [Fink broker](https://github.com/astrolabsoftware/fink-broker).

## Step 0: Set up your development environment

### fink-filters

Fork and clone the [fink-filters](https://github.com/astrolabsoftware/fink-filters) repository, and create a new folder in `fink_filters`. The name of the new folder does not matter much, but try to make it meaningful as much as possible! Let's call it `filter_rrlyr` for the sake of this example. This is where we will put our filter.

### Apache Spark & alert data

Running entirely Fink just for testing a filter might be an overwhelming task. Fink can be a complex system, but hopefully it is highly modular such that you do not need all the parts to test one part in particular. In principle, to test a filter you only need Apache Spark installed, and processed data by Fink.

Concerning the alerts, you can just use the Data Transfer service (https://fink-portal.org/download), and transfer some nights to you computer. For Spark, just go to https://archive.apache.org/dist/spark, and choose Spark version 3.1.3, with Hadoop 3.2. Download it, uncompress, and add these three lines in your init file (`.bash_rc`, `.bash_profile`, etc.):

```
export SPARK_HOME=/path/to/spark-3.1.3-bin-hadoop3.2
export PATH=$PATH:$SPARK_HOME/bin
export PYTHONPATH=$PYTHONPATH:$SPARK_HOME/python
```

Spark API exposes nearly the same methods for static or streaming DataFrame. Hence, to avoid complication due to streaming (e.g. creating streams with Kafka, reading streams, managing offsets, etc...), it is always best to prototype on static DataFrame. If the logic works for static, it will work for streaming :-)

## Step 1: Define your filter

A filter is typically a Python routine that selects which alerts need to be sent based on user-defined criteria. Criteria are based on the alert entries: position, flux, properties, ... You can find what's in alert here [link to be added].

In this example, let's imagine you want to receive all alerts flagged as RRLyr by the xmatch module. You would create a file called `filter.py` and define two routines:

```python
import pandas as pd
from pyspark.sql.functions import pandas_udf
from pyspark.sql.types import BooleanType

def rrlyr_(cdsxmatch: pd.Series) -> pd.Series:
    """ Return alerts identified as RRLyr by the xmatch module.

    Parameters
    ----------
    cdsxmatch: Spark DataFrame Column
        Alert column containing the cross-match values

    Returns
    ----------
    out: pandas.Series of bool
        Return a Pandas Series with the appropriate flag:
        false for bad alert, and true for good alert.

    """
    # Here goes your logic
    mask = cdsxmatch.values == "RRLyr"

    return pd.Series(mask)

@pandas_udf(BooleanType()) # <- mandatory
def rrlyr(cdsxmatch: pd.Series) -> pd.Series:
    """ Pandas UDF version for rrlyr_

    Parameters
    ----------
    cdsxmatch: Spark DataFrame Column
        Alert column containing the cross-match values

    Returns
    ----------
    out: pandas.Series of bool
        Return a Pandas Series with the appropriate flag:
        false for bad alert, and true for good alert.

    """
    # Here goes your logic
    myfilter = rrlyr_(cdsxmatch)

    return myfilter
```

Remarks:

- Note the use of the decorator is mandatory. It is a decorator for Apache Spark, and it specifies the output type. The type of operation is defined using type hints. More information at https://www.databricks.com/blog/2020/05/20/new-pandas-udfs-and-python-type-hints-in-the-upcoming-release-of-apache-spark-3-0.html.
- The name of the routine will be used as the name of the Kafka topic. So once the filter loaded, you would subscribe to the topic `*rrlyr*` to receive alerts from this filter. Hence choose a meaningful name!
- The name of the input argument must match the name of an alert field. Here `cdsxmatch` is one column added by the xmatch module. See [here](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html) for the available ZTF alert fields.
- You can have several input columns. Just add them one after the other:


```python
@pandas_udf(BooleanType()) # <- mandatory
def filter_w_several_input(acol: Any, anothercol: Any) -> pd.Series:
    """ Documentation """
    pass
```

Do not forget to include the `__init__.py` file in your new folder to make it a package.

## Step 2: Test your filter in the broker

Once your filter is written, it is time to test it on mock data!

...

It means your filter is taken into account by the broker! You can estimate the data volume sent by your filter on mock data following the [tutorial](db-inspection.md#example-2-forecasting-the-yield-of-a-science-filter).

## Step 3: Open a pull request

Once your filter is done, we will review it. The criteria for acceptance are:

- The filter works ;-)
- The volume of data to be transferred is tractable on our side.

Keep in mind, LSST incoming stream is 10 million alerts per night, or ~1TB/night. Hence your filter must focus on a specific aspect of the stream, to reduce the outgoing volume of alerts. Based on your submission, we will also provide estimate of the volume to be transferred.

## Step 4: Play!

If your filter is accepted, it will be plugged in the broker, and you will be able to receive your alerts in real-time using the [fink-client](https://github.com/astrolabsoftware/fink-client). Note that we do not keep alerts forever available in the broker. While the retention period is not yet defined, you can expect emitted alerts to be available no longer than one week.
