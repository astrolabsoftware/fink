# Redistributing Alerts using Kafka

One goal of the broker is to redistribute alert packets to the community. Therefore we have developed a service for streaming out alerts from the database to the world.

## Components

The major components of Fink's distribution system are:

1. **Fink's Alert Stream**
2. **Slack Alerts (experimental)**
3. **Fink Client**

## Fink's Alert Stream

Fink redistributes the alerts it receive from telescopes via Kafka topics. These topics are based on classification done while processing the alerts. The main components of alert stream are:

### Kafka Cluster

The Kafka Cluster consists of one or more Kafka broker(s) and a Zookeeper server that monitors and manages the Kafka brokers.
It is important to note that the Kafka Cluster for redistribution of alerts is different from the one used in [simulator](../tutorial/simulator.md).
<br>
You will need [Apache Kafka](https://kafka.apache.org/) 2.2+ installed. For testing purposes, you can run the install script at `conf/install_kafka.sh`. Once installed, define `KAFKA_HOME` as per your installation in your ~/.bash_profile.

```bash
# in ~/.bash_profile
# as per your Kafka installation directory
export KAFKA_HOME=/usr/local/kafka
```
<br>
We provide a script `fink_kafka` to efficiently manage the Kafka Cluster for redistribution. The help message shows the available
services:

```plain
Manage Fink's Kafka Server for Alert Distribution

 Usage:
 	fink_kafka [option]

 Option:
 	start
 		Starts Zookeeper Server and a Kafka Cluster

 	stop
 		Stops the running Kafka Cluster and Zookeeper Server

 	-h, --help
 		To view this help message

 	--create-topic <TOPIC>
 		Creates a topic named <TOPIC> if it does not already exist

 	--delete-topic <TOPIC>
 		Deletes an existing topic <TOPIC>

 	--describe-topic <TOPIC>
 		Lists out details for the given topic <TOPIC>

 	--list-topics
 		Lists all the topics

 	--authentication [-a] [-d] [-u user] [-p password] [-h]
 		Authenticate users on Fink's Kafka Cluster (use -h for more help)

 	--authorization [-a] [-d] [-u user] [-H host] [-c consumer-group] [-p] [-t topic] [-h]
 		Authorize permissions on Fink's Kafka Cluster (use -h for more help)

 	--list-acl
 		Lists the current ACL
```

### Spark process

A Spark process is responsible for reading the alert data from the Science Database,
converting the data into avro packets and publishing them to Kafka topic(s).
<br>
To see the working of the distribution system, first start Fink's Kafka Cluster
and create a topic "fink_outstream":

```bash
# Start the Kafka Cluster
fink_kafka start
# Create a test topic
fink_kafka --create-topic fink_outstream
```

This will start the Kafka Cluster and create a topic "fink_outstream" if it didn't already exist.
Set the topic in the [configuration](configuration.md).
```
DISTRIBUTION_TOPIC=fink_outstream
```
Now, start the distribution service:

```bash
# Start the distribution service
fink start distribution
```
This results in the following:<br>

- A Spark process starts reading the Science Database. It scans the
database for new records and publish them to Kafka Servers.

- The records are converted to binary(avro) before they are published and the schema is stored at the path given in configuration:

```bash
DISTRIBUTION_SCHEMA=${FINK_HOME}/schemas/distribution_schema
```

This schema can be used by a consumer service to read and decode the Kafka messages. To learn more about configuring Fink see [configuration](configuration.md).
<br><br>
To check the working of the distribution pipeline we provide a Spark Consumer that reads the messages published
on the topic given in configuration (here `fink_outstream`) and uses the schema
above to convert them back to a Spark DataFrame. This can be run using:

```bash
fink start distribution_test
```
This starts a Spark streaming process that reads the Kafka messages
published by the above distribution service, decodes them and print
the resulting DataFrame on console.

### Filtering of alerts before distribution

It is expensive (resource-wise) to redistribute the whole stream of alerts
received from telescopes. Hence Fink adds value to the alerts and distribute a
filtered stream of alerts. to learn more about this filtering service for redistribution, see the See the [distribution](../distribution/introduction.md) page or [`fink-filters`](https://github.com/astrolabsoftware/fink-filters) for more details.

### Security

To prevent unauthorized access of resources, it is important to add a layer of security
to the Kafka Cluster used for Alert Redistribution. More about Kafka security can be
learnt from Apache Kafka's official [documentation](https://kafka.apache.org/documentation/#security).

The security measures used for Fink's Kafka Cluster are:

1. Authentication of connections to brokers from clients (producers and consumers)
   and other brokers.
2. Authorization of read / write permissions to clients.

**Authentication**

Currently, Fink uses SASL/SCRAM-SHA-512 as the mechanism for authentication of
clients and brokers on the Kafka Cluster. SCRAM stands for
Salted Challenge Response Authentication Mechanism. The SCRAM credentials for
clients and brokers are stored in Zookeeper in non human-readable format. To ensure
security, Zookeeper must be in a secured network.

The credentials for a client can be added using the `--authentication` option
of `fink_kafka`.

Execute `fink_kafka --authentication -h` to get the help message:
```plain
Usage:
       fink_kafka --authentication [-a] [-d] [-u user] [-p password] [-h]

Add/delete credentials for user's authentication
       -a: add user's credentials (default)
       -d: delete user's credentials (optional)
       -u: username
       -p: password (not required for delete)
       -h: to view this help message
```

**Authorization**

Simple ACL authorizer that is shipped with Kafka is used for authorization of clients
and brokers on the Kafka Cluster. To learn more about Authorization and ACLs
in Kafka, refer to the official [documentation](https://kafka.apache.org/documentation/#security_authz).

The Access Control Lists (ACLs) are stored in Zookeeper.
Again, to ensure security, Zookeeper must be in secured network.

The most common use of Authorization and ACLs is to give permissions to clients
to act as consumer / producer. This can be achieved by using the `--authorization`
option of `fink_kafka`.

Execute `fink_kafka --authorization -h` to get the help message:
```plain
Usage:
       fink_kafka --authorization [-a] [-d] [-u user] [-H host] [-c consumer-group] [-p] [-t topic] [-h]

Add/delete ACLs for authorization on Fink's Kafka Cluster
       -a: add Acl
       -d: delete/remove Acl
       -u: username (Principal)
       -H: IP address from which Principal will have access (using hostname is not supported)
       -c: give access rights for a consumer (argument required: consumer-group)
       -p: give access rights for a producer
       -t: topic
       -h: to view this help message
```

To quickly view the current ACL execute `fink_kafka --list-acl`

## Slack Alerts (experimental)

Fink provides a utility to send out notifications and alert information via slack to the users' community. This is provided in the module `fink_broker.slackUtils`.

Usage:

First, set `SLACK_API_TOKEN` in the configuration file.

Sending messages to slack channels or individual users:
```python
from fink_broker.slackUtils import get_slack_client
finkSlack = get_slack_client()

# Sending message to a channel
channel = "#newsletter"
message = "New version of Fink is released"
finkSlack.send_message(channel, message)

# Sending message to individual user
user = "Bob"
message = "Your submitted query is complete"
finkSlack.send_message(user, message)
```

Along with sending out alerts via Kafka stream, slack can also be used to send out information about the classification of alerts. For example, to send slack alerts with information of coordinates and the classified type the method `send_slack_alerts` can be used:

```python
from fink_broker.slackUtils import send_slack_alerts

# DataFrame with alerts read from science db
df = read_science_db()
df.show()
send_slack_alerts(df)
```
This will result in alerts being sent to different channels corresponding to the classification type. For example if the dataframe contains the alert data as folllowing (output of `df.show()`):
```plain
+------------+------------------+----------------------------+-------------+------------+-------------+
|    objectId|            candid|cross_match_alerts_per_batch|candidate_pid|candidate_ra|candidate_dec|
+------------+------------------+----------------------------+-------------+------------+-------------+
|ZTF17aabuwws|697252840615015002|                       RRLyr| 697252840615|  12.5901418|  -13.2635671|
|ZTF17aabuxzj|697252841215010003|                     EB*WUMa| 697252841215|   9.8194532|   -12.512629|
|ZTF18abosdxh|697252845515010007|                       RRLyr| 697252845515|  13.8237084|   -7.6134186|
|ZTF18acsbtwe|697252844515015002|                     Unknown| 697252844515|    8.717752|   -8.2367741|
+------------+------------------+----------------------------+-------------+------------+-------------+
```
`send_slack_alerts` will result in alerts being sent to correspondig slack channel.

channel: `rrlyr` on slack:
```plain
+------------+------------+-------------+----------------------------+
|objectId    |candidate_ra|candidate_dec|cross_match_alerts_per_batch|
+------------+------------+-------------+----------------------------+
|ZTF17aabuwws|12.5901418  |-13.2635671  |RRLyr                       |
|ZTF18abosdxh|13.8237084  |-7.6134186   |RRLyr                       |
+------------+------------+-------------+----------------------------+
```

channel: `ebwuma` on slack:
```plain
+------------+------------+-------------+----------------------------+
|objectId    |candidate_ra|candidate_dec|cross_match_alerts_per_batch|
+------------+------------+-------------+----------------------------+
|ZTF17aabuxzj|9.8194532   |-12.512629   |EB*WUMa                     |
+------------+------------+-------------+----------------------------+
```

## Fink Client

Fink provides a light weight package to connect to the fink broker and receive the alert stream. See the [distribution](../distribution/introduction.md) page or [`fink-client`](https://github.com/astrolabsoftware/fink-client) for more details.
