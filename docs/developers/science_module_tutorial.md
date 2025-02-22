# Create your ZTF science module

!!! example ""
    This tutorial goes step-by-step for creating a science modules used to generate added values to ZTF alerts. It is expected that you know the basics of Python and Pandas. The use of Apache Spark is a plus. If you are not at ease with software development, that is also fine! Just contact us with your scientific idea, and we will help you designing the module.

Running entirely Fink just for testing a module might be an overwhelming task. Fink can be a complex system, but hopefully it is highly modular such that you do not need all the parts to test one part in particular. In principle, to test a module you only need Apache Spark installed, and alert data. Spark API exposes nearly the same methods for static or streaming DataFrame. Hence, to avoid complication due to streaming (e.g. creating streams with Kafka, reading streams, managing offsets, etc...), it is always best to prototype on static DataFrame. If the logic works for static, it will work for streaming.

## Development environment

First fork and clone the [fink-science](https://github.com/astrolabsoftware/fink-science) repository on your machine, and create a new folder in `fink_science/`. The name of the folder does not matter much, but try to make it meaningful as much as possible!

To make sure you are working in the correct environment, with exact version of dependencies used by Fink, we recommend to use the Fink Docker image. Download the image and mount your version of fink-science in a container:

```bash
# 2.3GB compressed
docker pull julienpeloton/fink-ci:latest

# Assuming you are in /path/to/fink-science
docker run -t -i --rm -v \
  $PWD:/home/libs/fink-science \ # (1)!
  julienpeloton/fink-ci:latest bash
```

1. Mount a volume for persisting data generated by and used by you in the Docker container.

The advantage of this method is that you have everything installed in it (Python and various frameworks). Beware, it is quite big... You should see some logs appearing when entering the container (this is ok). Finally activate the environment and remove the pre-installed version of `fink-science` from the container:

```bash
pip uninstall -y fink-science
```

## Science module design

A module contains necessary routines and classes to process the alert data, and add values. In this simple example, we explore a simple science module that takes magnitude measurements contained in each alert, and computes the change in magnitude between the last two measurements. A full example can be found at [https://github.com/astrolabsoftware/fink-science/tree/master/tutorial](https://github.com/astrolabsoftware/fink-science/tree/master/tutorial).

A science module will typically contains two parts: the processor that contains the main routine called by Fink, and any other modules used by the processor:

```bash
.
├── fink_science
│   ├── dyson_sphere_classifier
│   │   ├── __init__.py
│   │   ├── processor.py # (1)!
│   │   └── mymodule.py
```

1. The filename `processor.py` is mandatory. All the remaining files or folders can have any names.

The processor will typically look like:

```python
from line_profiler import profile # (1)!

from pyspark.sql.functions import pandas_udf
from pyspark.sql.types import FloatType

import pandas as pd

from fink_science.dyson_sphere_classifier.mymodule import super_magic_funtion

@pandas_udf(FloatType())
@profile
def myprocessor(objectId: pd.Series, magpsf: pd.Series, anothercolumn: pd.Series) -> pd.Series:
    """ Documentation please!
    """
    # your logic goes here
    output = super_magic_funtion(*args)

    # Return a column
    return pd.Series(output)
```

1. The use of a profiler will help us to understand performance bottlenecks, and optimise your code.

!!! warning "Remarks"
    - The use of the decorator is mandatory. It is a decorator for Apache Spark, and it specifies the output type as well as the type of operation.
    - You can return only one new column (i.e. add one new information per module). However the column can be nested (i.e. containing lists or dictionaries as elements).

## Science module test

The more tests the better! Typically, we expect at least unit tests using [doctest](https://docs.python.org/3/library/doctest.html) for all functions (see an example [here](https://github.com/astrolabsoftware/fink-science/blob/be9de75bdf8727c96e0e5574d05805f1fa3fdbe8/fink_science/random_forest_snia/processor.py#L119-L146)). Once you have written your unit tests, you can easily run them:

```bash
# in /home/libs/fink-science
./run_tests.sh --single_module fink_science/dyson_sphere_classifier/processor.py
```

you should see some harmless Spark logs in the form

```
/spark-3.4.1-bin-hadoop3/python/pyspark/sql/pandas/functions.py:399: UserWarning:
In Python 3.6+ and Spark 3.0+, it is preferred to specify type hints for pandas UDF
instead of specifying pandas UDF type which will be deprecated in the future releases.
See SPARK-28264 for more details.
```

then if you do not have errors, you will see the coverage report:

```bash
Combined data file .coverage.peloton.494915.XGtzWZRx
...
...

Name                                                        Stmts   Miss  Cover   Missing
-----------------------------------------------------------------------------------------
...
fink_science/dyson_sphere_classifier/processor.py              13      6    54%   39-42, 59-61
...
-----------------------------------------------------------------------------------------
TOTAL                                                        1971   1904     3%
Wrote HTML report to htmlcov/index.html
```

## Need more representative test data?

There is test data in fink-science already, but it might not be enough representative of your science case. In that case, the best is to use the [Data Transfer](https://fink-portal.org/download) service to get tailored data for your test.

!!! warning "Authentication"
    Make sure you have an account to use the [fink-client](https://github.com/astrolabsoftware/fink-client).

Once you have an account, install it and register your credentials on the container:

```bash
# Install the client
pip install fink-client

# register using your credentials
fink_client_register ...
```

Trigger a job on the Data Transfer service and download data in your container (July 12 2024 is good to start, only 17k alerts):

```bash
# Change accordingly
TOPIC=ftransfer_ztf_2024-07-16_682277

mkdir -p /data/$TOPIC
fink_datatransfer \
            -topic $TOPIC \
            -outdir /data/$TOPIC \
            -partitionby finkclass \
            --verbose
```

and specify this data path in your test:

```python
# usually at the end of processor.py

...

if __name__ == "__main__":
    """ Execute the test suite """

    globs = globals()

    custom_path = "file:///data/ftransfer_ztf_2024-07-16_682277"
    globs["custom_path"] = custom_path

    ...

```

## Submit your science module

Once you are ready (either the module is done, or you are stuck and want help), open a [Pull Request](https://github.com/astrolabsoftware/fink-science/pulls) on the fink-science repository on GitHub, and we will review the module and test it extensively before deployment. Among several things, we will perform profiling and performance tests as long running times add delay for further follow-up observations. See [fink-science-perf](https://github.com/astrolabsoftware/fink-science-perf) for more information.

Once your module is accepted and deployed, outgoing alerts will contain new information! You can then define your filter using [fink-filters](https://github.com/astrolabsoftware/fink-filters), and you will then be able to receive these alerts in (near) real-time using the [fink-client](https://github.com/astrolabsoftware/fink-client), or access them at any time in the Science Portal.
