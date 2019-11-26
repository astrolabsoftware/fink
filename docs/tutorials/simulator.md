# Fink simulator

For testing purposes, Fink uses an external service to simulate incoming streams: [fink-alert-simulator](https://github.com/astrolabsoftware/fink-alert-simulator). With this stream simulator package, you can easily develop applications locally and deploy at scale only when you are ready!

## Installation

See [Getting Started](../broker/introduction.md) to install the simulator.

## Using ZTF data

The service is provided through docker-compose, and include Kafka and Zookeeper clusters deployment. The simulator generates the stream from alerts stored on disk. We provide a script to download a subset of ZTF alerts that will be used to generate streams:

```bash
cd ${FINK_HOME}/datasim
./download_ztf_alert_data.sh
# ...download 499 alerts
```

You can change this folder with your data, but make sure you correctly set the schema and the data path in the configuration:

```bash
# in configuration file
FINK_ALERT_SCHEMA=...
FINK_DATA_SIM=...
```

## Sending alerts to the broker

By default alerts will be published on the port 29092 (localhost), but you can change it in the configuration file (see `conf/fink-alert-simulator.conf`). To start the simulator and send alerts, just execute:

```bash
# the --docker specifies a local run using docker-compose
fink_simulator --docker
```

With the default configuration, it will generate 4 observations (`NOBSERVATIONS`) of 3 alerts each (`NALERTS_PER_OBS`). Data will be published on the IP/PORT `localhost:29092` (`KAFKA_IPPORT_SIM`) in a topic called `ztf-stream-sim` (`KAFKA_TOPIC`), at regular interval of 5 seconds between two observations (`TIME_INTERVAL`). You can change all of it in the configuration file. Note you cannot publish more alerts than what is available on disk. All fink-broker services can be run on the simulated stream by just specifying the argument `--simulator`:

```bash
fink start <service> --simulator
```

Always make sure that the Kafka properties are the same between the fink-alert-simulator (producer) and the fink-broker (consumer):

```
##############
# This block is in both
#   * conf/fink.conf (fink-broker)
#   * conf/fink-alert-simulator.conf (fink-alert-simulator)
##############

# Local mode (Kafka cluster is spun up on-the-fly in docker).
KAFKA_PORT_SIM=29092
KAFKA_IPPORT_SIM="localhost:${KAFKA_PORT_SIM}"

# Cluster mode - you would a Kafka cluster installed with write mode.
KAFKA_IPPORT=""

# Topic name for the producer
KAFKA_TOPIC="ztf-stream-sim"
```

For example for demo purposing, you can easily start the monitoring service on the simulated stream with:

```bash
fink start checkstream --simulator
```

and watch the incoming stream after sending alerts (`fink_simulator --docker`).
