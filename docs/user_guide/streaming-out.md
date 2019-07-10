# Redistributing Alerts

One goal of the broker is to redistribute alert packets to the community. Therefore we have developed a service for streaming out alerts from the database to the world.

## Components

The two major components of Fink's distribution system are:

1. Kafka Cluster
2. Spark Process (which acts as the Producer)

## Kafka Cluster
The Kafka Cluster consists of one or more Kafka broker(s) and a Zookeeper server that monitors and manages the Kafka brokers.
It is important to note that the Kafka Cluster for Redistribution of alerts is different from the one used in [simulator](simulator.md).
<br>
You will need [Apache Kafka](https://kafka.apache.org/) 2.2+ installed. You can run the install script at `conf/install_kafka.sh`. Once installed, define `KAFKA_HOME` as per your installation in your ~/.bash_profile.

```bash
# in ~/.bash_profile
# as per your Kafka installation directory
export KAFKA_HOME=/usr/local/kafka
```
<br>
We provide a script `fink_kafka` to efficiently manage the Kafka Cluster for Redistribution. The help message shows the available
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
```

## Spark process
The Spark process is responsible for reading the alert data from the [Science Database](database.md#science-database-structure),
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
To check the working of the distribution pipelline we provide a Spark Consumer that reads the messages published
on the topic given in configuration (here `fink_outstream`) and uses the schema
above to convert them back to a Spark DataFrame. This can be run using:

```bash
fink start distribution_test
```
This starts a Spark streaming process that reads the Kafka messages
published by the above distribution service, decodes them and print
the resulting DataFrame on console.

## Filtering alerts before distribution
It is expensive (resource-wise) to redistribute the whole stream of alerts
received from telescopes. Hence Fink adds value to the alerts and distribute a
filtered stream of alerts. This filtering service for redistribution is called level two (level one operates in between the stream and the database, see [Tutorial2](bogus_filtering.md)). Currently there are two ways for user to specify their filters:

- Simple rules based on key-value can be defined using an xml file. See `conf/distribution-rules.xml` for more details. These rules are applied to obtain a filtered stream which is then distributed on Kafka topic(s).
- Python function stored under `${FINK_HOME}/userfilters/leveltwo.py`.

## Security
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
