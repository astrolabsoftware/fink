# Create your science module for Fink

This tutorial goes step-by-step for creating a science modules used to generate added values to ZTF alert collected by the [Fink broker](https://github.com/astrolabsoftware/fink-broker).

## Step 0: Set up your development environment

### fink-science

Fork and clone the [fink-science](https://github.com/astrolabsoftware/fink-science) repository, and create a new folder in `fink_science/`. The name of the folder does not matter much, but try to make it meaningful as much as possible! Let's call it `xmatch` for the sake of this example. This is where we will put our science module.

### fink-broker

If you want to be able to test your science module inside the broker, you will need to install it. You have two options:

* Local installation: see [Local use](../broker/introduction.md#installation-local-mode)
* Docker installation: see [Docker use](../broker/introduction.md#use-with-docker)

Note that we will also test your science module before launching it in production.

## Step 1: Develop your science module

A module contains necessary routines and classes to process the data, and add values. Typically, you will receive alerts in input, and output the same alerts with additional information. Input alert information contains position, flux, telescope properties, ... You can find what information is available in an alert [here]([ZTF alerts schema](https://zwickytransientfacility.github.io/ztf-avro-alert/)), or check the current Fink [added values](../science/added_values.md).

In this example, let's imagine you want to know if alerts have counterpart (cross-match) in the Simbad database based on their localisation on the sky. We wrote a small library containing all the routines (see the [fink_science/xmatch](https://github.com/astrolabsoftware/fink-science/tree/master/fink_science/xmatch) folder), and we now write the `processor` in `processor.py` (name of the file needs to be `processor.py`):

```python
@pandas_udf(StringType(), PandasUDFType.SCALAR) # <- mandatory
def cdsxmatch(objectId: Any, ra: Any, dec: Any) -> pd.Series:
    """ Query the CDSXmatch service to find identified objects
    in alerts. The catalog queried is the SIMBAD bibliographical database.

    Parameters
    ----------
    objectId: list of str or Spark DataFrame Column of str
        List containing object ids (custom)
    ra: list of float or Spark DataFrame Column of float
        List containing object ra coordinates
    dec: list of float or Spark DataFrame Column of float
        List containing object dec coordinates

    Returns
    ----------
    out: pandas.Series of string
        Return a Pandas DataFrame with the type of object found in Simbad.
        If the object is not found in Simbad, the type is
        marked as Unknown. In the case several objects match
        the centroid of the alert, only the closest is returned.
        If the request Failed (no match at all), return Column of Fail.

    Examples
    -----------
    Simulate fake data
    >>> ra = [26.8566983, 26.24497]
    >>> dec = [-26.9677112, -26.7569436]
    >>> id = ["1", "2"]

    Wrap data into a Spark DataFrame
    >>> rdd = spark.sparkContext.parallelize(zip(id, ra, dec))
    >>> df = rdd.toDF(['id', 'ra', 'dec'])
    >>> df.show() # doctest: +NORMALIZE_WHITESPACE
    +---+----------+-----------+
    | id|        ra|        dec|
    +---+----------+-----------+
    |  1|26.8566983|-26.9677112|
    |  2|  26.24497|-26.7569436|
    +---+----------+-----------+
    <BLANKLINE>

    Test the processor by adding a new column with the result of the xmatch
    >>> df = df.withColumn(
    ... 	'cdsxmatch', cdsxmatch(df['id'], df['ra'], df['dec']))
    >>> df.show() # doctest: +NORMALIZE_WHITESPACE
    +---+----------+-----------+---------+
    | id|        ra|        dec|cdsxmatch|
    +---+----------+-----------+---------+
    |  1|26.8566983|-26.9677112|     Star|
    |  2|  26.24497|-26.7569436|  Unknown|
    +---+----------+-----------+---------+
    <BLANKLINE>
    """
    # your logic goes here
    matches = cross_match_alerts_raw(
        objectId.values, ra.values, dec.values)

    # For regular alerts, the number of matches is always non-zero as
    # alerts with no counterpart will be labeled as Unknown.
    # If cross_match_alerts_raw returns a zero-length list of matches, it is
    # a sign of a CDS problem (logged).
    if len(matches) > 0:
        # (objectId, ra, dec, name, type)
        # return only the type.
        names = np.transpose(matches)[-1]
    else:
        # Tag as Fail if the request failed.
        names = ["Fail"] * len(objectId)

    # Return a column with added value after processing
    return pd.Series(names)
```

Remarks:

- Note the use of the decorator is mandatory. It is a decorator for Apache Spark, and it specifies the output type as well as the type of operation. You need to specify the output type (string in this example).
- The name of the routine will be used as the name of the new column. So once the processor loaded, you cannot change it! Hence choose a meaningful name!
- The name of the input argument(s) must match the name of an alert entry(ies). See [here](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html) for the available ZTF alert fields.
- You can return only one new column (i.e. add one new information per module).

Do not forget to include the `__init__.py` file in your new folder to make it a package.

## Step 2: Test your science module in the broker

Once your science module is written, it is time to test it on mock data! First of all, make sure you installed fink-broker correctly (see above) and fink-science is in your `PYTHONPATH`. Edit the `bin/raw2science.py` file and call your science module:

```python
from fink_science.xmatch.processor import cdsxmatch

...

# Apply level one processor: cdsxmatch
logger.info("New processor: cdsxmatch")
colnames = [
    df['objectId'],
    df['candidate.ra'],
    df['candidate.dec']
]
df = df.withColumn(cdsxmatch.__name__, cdsxmatch(*colnames))
```

Since your science module adds new values (i.e. new field in the alert data), the alert outgoing schema needs to be updated. Open the `schemas/distribution_schema.avsc` avro schema (JSON), and add information about your new field in the correct level (root or root.candidate, ...). In our case, `cdsxmatch` is at the root (same level as `topic` or `publisher`) and it is a string:

```json
...
{
  "name": "topic",
  "type": [
    "string",
    "null"
  ]
},
{
  "name": "cdsxmatch",
  "type": [
    "string",
    "null"
  ]
},
{
  "name": "publisher",
  "type": "string"
}
...
```

Finally deploy the broker (see the [tutorial](deployment.md)). Note that when launching the raw2science service, you must see the following lines at the end of the log:

```bash
20/01/07 13:10:08 INFO main (raw2science.py line 66): New processor: cdsxmatch
```

It means your science module is taken into account by the broker!

## Step 3: Open a pull request

Once your science module is done, we will review it. The criteria for acceptance are:

- The science module works ;-)
- The execution time is not too long.

We want to process data as fast as possible, and long running times add delay for further follow-up observations. What execution time is acceptable? It depends, but in any case communicate early the extra time overhead, and we can have a look together on how to speed-up the process if needed.

## Step 4: Play!

If your module is accepted, it will be plugged in the broker, and outgoing alerts will contain new information! Define your filter using [fink-filters](https://github.com/astrolabsoftware/fink-filters), and you will then be able to receive these alerts in (near) real-time using the [fink-client](https://github.com/astrolabsoftware/fink-client). Note that we do not keep alerts forever available in the broker. While the retention period is not yet defined, you can expect emitted alerts to be available no longer than one week.
