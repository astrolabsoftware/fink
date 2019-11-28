**Broker:** [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=finkbroker&metric=alert_status)](https://sonarcloud.io/dashboard?id=finkbroker) [![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=finkbroker&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=finkbroker)
[![Build Status](https://travis-ci.org/astrolabsoftware/fink-broker.svg?branch=master)](https://travis-ci.org/astrolabsoftware/fink-broker)
[![codecov](https://codecov.io/gh/astrolabsoftware/fink-broker/branch/master/graph/badge.svg)](https://codecov.io/gh/astrolabsoftware/fink-broker)

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

To use the broker on your laptop, you need Python 3.6+ and Apache Spark 2.4+ installed (see the [Spark installation](../tutorials/introduction.md#install-apache-spark)). Then clone the repository:

```bash
git clone https://github.com/astrolabsoftware/fink-broker.git
cd fink-broker
```

and install the required python dependencies:

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Finally, define `FINK_HOME` and add the path to the Fink binaries and modules in your `~/.bash_profile`:

```bash
# in ~/.bash_profile
export FINK_HOME=/path/to/fink-broker
export PYTHONPATH=$FINK_HOME:$PYTHONPATH
export PATH=$FINK_HOME/bin:$PATH
```

To test the broker, you also need to install the [Fink alert simulator](https://github.com/astrolabsoftware/fink-alert-simulator). This package is external to fink-broker to ease its use outside the broker. The simulator is based on Apache Kafka, and can be used via docker (you would need docker-compose installed). First clone the repo somewhere on your machine:

```bash
git clone https://github.com/astrolabsoftware/fink-alert-simulator.git
```

and update your `PYTHONPATH` and `PATH` to use the tools:

```bash
# in your ~/.bash_profile
export FINK_ALERT_SIMULATOR=/path/to/fink-alert-simulator
export PYTHONPATH=$FINK_ALERT_SIMULATOR:$PYTHONPATH
export PATH=$FINK_ALERT_SIMULATOR/bin:$PATH
```

Its usage is detailed in the simulator [tutorial](../tutorials/simulator.md).

## Use with docker

If you prefer using docker to test or make developments, we provide a Dockerfile of the broker. The image is based on ubuntu 16.04 and contains:

- java 8, kafka 2.2.0, spark 2.4.4, python 3.7
- fink-alert-simulator (cloned and on the master branch)

To build the image from the root of the repo, execute

```bash
docker build -t fink-broker .
```

and check the images are correctly built:

```
docker image ls
REPOSITORY                  TAG                 IMAGE ID            CREATED             SIZE
fink-broker                 latest              0220a667160c        2 hours ago         2.32GB
ubuntu                      16.04               56bab49eef2e        36 hours ago        123MB
confluentinc/cp-kafka       latest              be6286eb3417        2 months ago        590MB
confluentinc/cp-zookeeper   latest              711eb38827f6        2 months ago        590MB
```

Except the Fink alert simulator, the container does not contain other packages from the Fink ecosystem and you will need to mount them on run. This is to allow their edition from the host machine:

```bash
# Run the container
docker run --rm --tty --interactive \
  -v $FINK_HOME:/home/fink-broker \
  -v $FINK_SCIENCE:/home/fink-science \
  -v $FINK_FILTERS:/home/fink-filters \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --net host \
  fink-broker bash
```

Remarks:

* `FINK_SCIENCE` and `FINK_FILTERS` correspond to the paths to fink-science and fink-filters respectively in the host machine.
* For the mounted volumes, it is important to respect the container path scheme `/home/fink-*` as the container variables `PYTHONPATH` and `PATH` rely on it (otherwise use [--env](https://docs.docker.com/engine/reference/commandline/run/) to overwrite them).
* fink-science and fink-filters are optional and you could also just `pip install` them once inside the container.
* Finally note that the container does not run its own Docker daemon, but connects to the Docker daemon of the host system (`-v /var/run/docker.sock:/var/run/docker.sock`), and we specify the `host` network for the docker-compose of the container to work properly.

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

You should see plenty of Spark logs (and yet we have shut most of them!), but no failures hopefully! Success is silent, and the coverage is printed on screen at the end. You can disable integration tests by specifying the argument `--without-integration`. Note for docker users: you need to install fink-science and fink-filters (either mounted inside the container, or installed via pip) prior running the test suite. See above for more information.

Then let's test some functionalities of Fink by simulating a stream of alert, and monitoring it. In a terminal tab, connect the checkstream service to the stream:

```bash
fink start checkstream --simulator
```

in a second terminal tab, send a small burst of alerts (see `fink-alert-simulator` installation above):

```bash
fink_simulator --docker
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

 Available services are: checkstream, stream2raw, raw2science, distribution
 Typical configuration would be /Users/julien/Documents/workspace/myrepos/fink/conf/fink.conf

 To see the running processes:
 	fink show

 To initialise data folders and paths:
 	fink init

 To stop a service or all running processes:
 	fink stop <service or all>
```

More information can be found in the deployment [tutorial](../tutorials/deployment.md).
