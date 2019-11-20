# Tutorial: Fink broker main commands

We expose here the main commands to use the Fink broker:

- Launch a Fink pipeline
- Produce local stream of alerts
- Launch pyspark shell with Fink configuration pre-loaded
- Test Fink

For this tutorial, make sure:

* Fink is installed on your computer.
* Apache Spark (2.4+) is installed on your computer.
* Docker is installed on your computer.

You can also run this tutorial on the cloud, providing that Apache Spark is installed, you correctly set the IP and port in the configuration files, and you distribute the dependencies in all executors. Note that you would need to send alerts from a Kafka cluster yourself, or connect to an existing stream.

## Fink broker pipeline

An example to instantiate a simple version of the broker on your local computer:

```bash
#!/bin/bash
set -e

# Select a configuration file
CONF=conf/fink.conf

# Initialise paths
fink_init

# Redirect (driver) logs here
mkdir -p logs

# stream to raw DB
fink start stream2raw -c $CONF --simulator > logs/stream2raw.log &

sleep 5

# raw DB to science DB (incl. quality cuts and science modules)
fink start raw2science -c $CONF --simulator > logs/raw2science.log &

sleep 5

# Redistribute data (incl. filtering)
fink start distribution -c $CONF > logs/distribution.log &

# EXTRA: Read redistributed data to check it works
# Make sure you are using the same topic as was defined above
# fink start distribution_test -c $CONF
# ALTERNATIVE: you can use fink-client to read the outgoing alert stream.
```

If you were on the cloud, you would remove the `--simulator` argument, make sure to edit the configuration, and distribute dependencies in all executors.

## Launching stream of alerts (locally)

To launch a stream of alerts, just execute:

```bash
# Make sure you use the same configuration to read the stream
fink start simulator -c conf/fink.conf
```

The topic name is specified in the `conf/fink.conf` configuration file.

## Debugging using the Fink shell

The Fink shell is a pyspark shell with all dependencies for Fink loaded. It allows developers to get their environment set up directly for debugging:

```bash
# Default is pyspark shell with ipython as driver
fink_shell -c conf/fink.conf.shell
```

## Testing Fink

To launch the full test suite of the broker, just execute:

```bash
fink_test
```
