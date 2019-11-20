**Broker:** [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=finkbroker&metric=alert_status)](https://sonarcloud.io/dashboard?id=finkbroker) [![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=finkbroker&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=finkbroker)
[![Build Status](https://travis-ci.org/astrolabsoftware/fink-broker.svg?branch=master)](https://travis-ci.org/astrolabsoftware/fink-broker)
[![codecov](https://codecov.io/gh/astrolabsoftware/fink-broker/branch/master/graph/badge.svg)](https://codecov.io/gh/astrolabsoftware/fink-broker) [![Documentation Status](https://readthedocs.org/projects/fink-broker/badge/?version=latest)](https://fink-broker.readthedocs.io/en/latest/?badge=latest)

## The magic behind Fink

Fink is mainly based on the recent [Spark Structured Streaming](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html) module introduced in Spark 2.0 (see [paper](https://cs.stanford.edu/~matei/papers/2018/sigmod_structured_streaming.pdf)), and especially its integration with Apache Kafka (see [here](https://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html)). Structured streaming is a stream processing engine built on the Spark SQL engine, hence it combines the best of the two worlds.
The idea behind it is to process data streams as a series of small batch jobs, called micro-batch processing. As anything in Spark, it provides fast, scalable, fault-tolerant processing, plus end-to-end exactly-once stream processing.

## Broker structure

The broker is made of 4 modules:

* **stream2raw**: connect to incoming stream of alerts, and archive data on disk.
* **raw2science**: filter out bad quality alerts, and add values to remaining alerts using the user-defined science modules.
* **distribution**: redistribute alerts to users based on user-defined filters (Kafka topics).
* **archive**: store alerts containing scientific added values.

On the production platform, we typically have several medium-size clusters spun-up: Apache Spark, Apache Kafka, Apache HBase, ... but you can install and test all of these components in local mode, with moderate resources required.

## Installation (local mode)

You need Python 3.6+, Apache Spark 2.4+, and docker-compose (latest) installed.
Define `SPARK_HOME`  as per your Spark installation (typically, `/usr/local/spark`) and add the path to the Spark binaries in `.bash_profile`:

```bash
# in ~/.bash_profile
# as per your spark installation directory (eg. /usr/local/spark)
export SPARK_HOME=/usr/local/spark
export SPARKLIB=${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip
export PYTHONPATH=${SPARKLIB}:$PYTHONPATH
export PATH=${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}
```

Set the path to HBase
```bash
# in ~/.bash_profile
# as per your hbase installation directory (eg. /usr/local/hbase)
export HBASE_HOME=/usr/local/hbase
export PATH=$PATH:$HBASE_HOME/bin
```

and start the service:

```bash
$HBASE_HOME/bin/start-hbase.sh
```

Clone the repository:

```bash
git clone https://github.com/astrolabsoftware/fink-broker.git
cd fink-broker
```

Then install the required python dependencies:

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Finally, define `FINK_HOME` and add the path to the Fink binaries and modules in your `.bash_profile` (assuming you are using `bash`...):

```bash
# in ~/.bash_profile
export FINK_HOME=/path/to/fink-broker
export PYTHONPATH=$FINK_HOME:$PYTHONPATH
export PATH=$FINK_HOME/bin:$PATH
```

The [simulator](user_guide/simulator.md) relies on docker-compose.

## Getting started

The repository contains some alerts from the ZTF experiment required for the test suite in the folder `datasim`. If you need to download more alerts data, go to the datasim directory and execute the download script:

```bash
cd datasim
./download_ztf_alert_data.sh
cd ..
```

Make sure the test suite is running fine. Just execute:

```bash
fink_test [--without-integration] [-h]
```

You should see plenty of Spark logs (and yet we have shut most of them!), but no failures hopefully! Success is silent, and the coverage is printed on screen at the end. You can disable integration tests by specifying the argument `--without-integration`.


Then let's test some functionalities of Fink by simulating a stream of alert, and monitoring it. In a terminal tab, connect the checkstream service to the stream:
```bash
fink start checkstream --simulator > live.log &
```

in a second terminal tab, send a small burst of alerts:
```bash
fink start simulator
```
and see the alerts coming on your first terminal tab screen! You can easily see which service is running by using:

```bash
fink show
1 Fink service(s) running:
USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
julien           61200   0.0  0.0  4277816   1232 s001  S     8:20am   0:00.01 /bin/bash /path/to/fink start checkstream --simulator
Use <fink stop service_name> to stop a service.
Use <fink start dashboard> to start the dashboard or check its status.
```

Finally stop monitoring and shut down the UI simply using:
```bash
fink stop checkstream
```

To get help about `fink`, just type:

```shell
$ fink
Handle Kafka stream received by Apache Spark

 Usage:
 	to init paths : fink init [-h] [-c <conf>]
 	to start a service: fink start <service> [-h] [-c <conf>] [--simulator]
 	to stop a service : fink stop <service> [-h] [-c <conf>]
 	to show services : fink show [-h]

 To get this help:
 	fink

 To get help for a service:
 	fink start <service> -h

 Available services are: dashboard, checkstream, stream2raw, raw2science, distribution
 Typical configuration would be /Users/julien/Documents/workspace/myrepos/fink/docs/conf/fink.conf

 To see the running processes:
 	fink show

 To initialise data folders and paths:
 	fink init

 To stop a service or all running processes:
 	fink stop <service or all>
```

<!-- ## Datastore

The most critical part in a context of big data is to capture as fast as possible the stream, and store information efficiently and reliably. We start with one Spark Structured Streaming job reading and decoding Avro events sent from telescopes, and writing them to partitioned Parquet tables in distributed file systems such as HDFS (Raw database). Then multi-modal analytics take place and several other batch and streaming jobs query this table to process further the data, and push relevant alert data into an HBase table (Science database).

This main service is described in the [database](database.md) section.

## Services

### Services & dashboards

Fink provides built-in services, described in [Available Services](available-services.md). They operate at different timescales, and with various objectives:

- Operating from the stream or from the database
- Real time or post-processing of alerts.
- Urgent decision to take (observation plan).

Each service is Spark job on the database - either raw or science. All services are linked to the [dashboard](dashboard.md), and you can easily follow live and interactively the outputs. Note you can easily define your own service in Fink (i.e. your favourite ML code!), and connect it to the alert database. See [Adding a new service](adding-new-service.md) for more information.

### AstroLabNet

[AstroLabNet](https://hrivnac.web.cern.ch/hrivnac/Activities/Packages/AstroLabNet/) is a front-end to ease the manipulation of the science database (HBase). It allows to

* Access distributed data.
* Deploy jobs to data.
* Move data between servers.
* Arrange data streaming and updating.

Note that the development of AstroLabNet is done outside of Fink. Resources: [code source](https://github.com/hrivnac/AstroLabNet), [documentation](https://hrivnac.web.cern.ch/hrivnac/Activities/Packages/AstroLabNet/).

## Simulating alert data

In Fink, we want also to test our services before deploying them full-scale. We provide a simple stream simulator based on a dockerized Kafka & Zookeeper cluster:

```bash
fink start simulator
```

This will set up the simulator and send a stream of alerts. Then test a service in simulation mode by specifying `--simulator`:

```bash
fink start <service> --simulator
```

See [Simulator](simulator.md) for more information.

## Redistributing Alerts

Part of the incoming stream will be also redirected outside for other brokers and individual clients. See [Redistributing Alerts](streaming-out.md) for more information. -->