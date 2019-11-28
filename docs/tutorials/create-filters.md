# Create your filter for Fink

This tutorial goes step-by-step for creating a filters used to define which information will be sent to you by the [Fink broker](https://github.com/astrolabsoftware/fink-broker).

## Step 0: Set up your development environment

### fink-filters

Fork and clone the [fink-filters](https://github.com/astrolabsoftware/fink-filters) repository, and create a new folder in `fink_filters`. The name of the new folder does not matter much, but try to make it meaningful as much as possible! Let's call it `filter_rrlyr` for the sake of this example. This is where we will put our filter.

### fink-broker

If you want to be able to test your filter inside the broker, you will need to install it. You have two options:

* Local installation: see [Local use](../broker/introduction.md#installation-local-mode)
* Docker installation: see [Docker use](../broker/introduction.md#use-with-docker)

## Step 1: Define your filter

A filter is typically a Python routine that selects which alerts need to be sent based on user-defined criteria. Criteria are based on the alert entries: position, flux, properties, ... You can find what's in alert here [link to be added].

In this example, let's imagine you want to receive all alerts flagged as RRLyr by the xmatch module. You would create a file called `filter.py` and define a simple routine (see full template in the repo):

```python
@pandas_udf(BooleanType(), PandasUDFType.SCALAR) # <- mandatory
def rrlyr(cdsxmatch: Any) -> pd.Series:
    """ Return alerts identified as RRLyr by the xmatch module.

    Parameters
    ----------
    cdsxmatch: Spark DataFrame Column
        Alert column containing the cross-match values

    Returns
    ----------
    out: pandas.Series of bool
        Return a Pandas DataFrame with the appropriate flag:
        false for bad alert, and true for good alert.

    """
    # Here goes your logic
    mask = cdsxmatch.values == "RRLyr"

    return pd.Series(mask)
```

Remarks:

- Note the use of the decorator is mandatory. It is a decorator for Apache Spark, and it specifies the output type as well as the type of operation. Just copy and paste it for simplicity.
- The name of the routine will be used as the name of the Kafka topic. So once the filter loaded, you would subscribe to the topic `rrlyr` to receive alerts from this filter. Hence choose a meaningful name!
- The name of the input argument must match the name of an alert field. Here `cdsxmatch` is one column added by the xmatch module. See [here](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html) for the available ZTF alert fields.
- You can have several input columns. Just add them one after the other:


```python
@pandas_udf(BooleanType(), PandasUDFType.SCALAR) # <- mandatory
def filter_w_several_input(acol: Any, anothercol: Any) -> pd.Series:
    """ Documentation """
    pass
```

Do not forget to include the `__init__.py` file in your new folder to make it a package.

## Step 2: Test your filter in the broker

Once your filter is written, it is time to test it on mock data! First of all, make sure you installed fink-broker correctly (see above) and fink-filters is in your `PYTHONPATH`. Edit the `bin/distribution.py` file to register the path of your filter:

```python
# User-defined topics - python path to the filter
userfilters = [
    'fink_filters.filter_rrlyr.filter.rrlyr'
]
```

Then in the `conf/fink.conf.distribution` configuration file, edit the topic name:

```bash
# Kafka topic to publish on as defined by
# the name of your filter
DISTRIBUTION_TOPIC="rrlyr"
```

Finally deploy the broker (see the [tutorial](deployment.md)). Note that when launching the distribution service, you must see the following line at the end of the log:

```bash
19/11/28 14:22:10 INFO apply_user_defined_filter (filters.py line 239): new filter/topic registered: rrlyr from fink_filters.filter_rrlyr.filter
```

It means your filter is taken into account by the broker! You can estimate the data volume sent by your filter on mock data following the [tutorial](db-inspection.md#example-2-forecasting-the-yield-of-a-science-filter).

## Step 3: Open a pull request

Once your filter is done, we will review it. The criteria for acceptance are:

- The filter works ;-)
- The volume of data to be transferred is tractable on our side.

Keep in mind, LSST incoming stream is 10 million alerts per night, or ~1TB/night. Hence your filter must focus on a specific aspect of the stream, to reduce the outgoing volume of alerts. Based on your submission, we will also provide estimate of the volume to be transferred.

## Step 4: Play!

If your filter is accepted, it will be plugged in the broker, and you will be able to receive your alerts in real-time using the [fink-client](https://github.com/astrolabsoftware/fink-client). Note that we do not keep alerts forever available in the broker. While the retention period is not yet defined, you can expect emitted alerts to be available no longer than one week.
