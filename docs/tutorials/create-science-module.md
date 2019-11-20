## Create your science module for Fink

This tutorial goes step-by-step for creating a science modules used to generate added values to ZTF alert collected by the [Fink broker](https://github.com/astrolabsoftware/fink-broker).

### Step 0: Fork the fink-science repository

Fork and clone the [fink-science](https://github.com/astrolabsoftware/fink-science) repository, and create a new folder in `fink_science/`. The name of the folder does not matter much, but try to make it meaningful as much as possible! Let's call it `xmatch` for the sake of this example.

### Step 1: Define your science module

A module contains necessary routines and classes to process the data, and add values. Typically, you will receive alerts in input, and output the same alerts with additional information. Input alert information contains position, flux, telescope properties, ... You can find what information is available in an alert [here](../science/ztf_alerts.md), or check the current Fink [added values](../science/added_values.md).

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

### Step 3: Open a pull request

Once your filter is done, we will review it. The criteria for acceptance are:

- The science module works ;-)
- The execution time is not too long.

We want to process data as fast as possible, and long running times add delay for further follow-up observations. What execution time is acceptable? It depends, but in any case communicate early the extra time overhead, and we can have a look together on how to speed-up the process if needed.

### Step 4: Play!

If your module is accepted, it will be plugged in the broker, and outgoing alerts will contain new information! Define your filter using [fink-filters](https://github.com/astrolabsoftware/fink-filters), and you will then be able to receive these alerts in (near) real-time using the [fink-client](https://github.com/astrolabsoftware/fink-client). Note that we do not keep alerts forever available in the broker. While the retention period is not yet defined, you can expect emitted alerts to be available no longer than one week.
