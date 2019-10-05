# Tutorial: Redistributing alerts

**Context**

This tutorial illustrates the basics of connecting to the raw database (Parquet), filtering out alerts that do not satisfy quality criteria, pushing them to the science database, and redistributing those alerts via Apache Kafka.

**Before starting**

For this tutorial, make sure:

* Fink is installed on your computer.
* Apache Spark (2.4+) is installed on your computer.
* Docker is installed on your computer.
* Apache HBase is installed on your computer.
* Apache Kafka is installed on your computer (steps below).

See [Getting started](../index.md) for more information.

## Setting the Kafka cluster

The Kafka Cluster consists of one or more Kafka broker(s) and a Zookeeper server that monitors and manages the Kafka brokers.
It is important to note that the Kafka Cluster for Redistribution of alerts is different from the one used in [simulator](simulator.md).
<br>
You will need [Apache Kafka](https://kafka.apache.org/) 2.2+ installed. For a local installation, you can run the install script at `conf/install_kafka.sh`. For a full cluster installation, you might need to follow the official documentation or have a look at this [tutorial](https://github.com/JulienPeloton/mini_spark_broker/blob/master/notes/benchmark.md). Once installed, define `KAFKA_HOME` as per your installation in your ~/.bash_profile.

```bash
# in ~/.bash_profile
# as per your Kafka installation directory
export KAFKA_HOME=/usr/local/kafka
```
<br>
We provide a script `fink_kafka` to efficiently manage the Kafka Cluster for Redistribution. The help message shows the available services:

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

Finally start Fink's Kafka Cluster:

```bash
# Start the Kafka Cluster
fink_kafka start
```

## Filtering for RRLyr

It is expensive (resource-wise) to redistribute the whole stream of alerts
received from telescopes. Hence Fink adds value to the alerts and distribute a
filtered stream of alerts. This filtering service for redistribution is called level two (level one operates in between the stream and the database, see [Tutorial2](bogus_filtering.md)). Currently there are two ways for user to specify their filters:

- Simple rules based on key-value can be defined using an xml file. See `conf/distribution-rules.xml` for more details. These rules are applied to obtain a filtered stream which is then distributed on Kafka topic(s).
- Python function stored under `${FINK_HOME}/userfilters/leveltwo.py`.

We will focus here on the first kind. Let's imagine we want to redirect all alerts flagged as RRlyr by the cross-match service running downstream (see [Tutorial3](processing_alerts.md)). The first step is to create such filter. Create a file `conf/distribution-rules_rrlyr.xml` with inside:

```xml
<?xml version="1.0"?>

<!-- distribution.dtd -->
<!DOCTYPE distribution-rules [
  <!ELEMENT distribution-rules (select, drop?, filter?) >
  <!ELEMENT select (column+) >
  <!ELEMENT drop (column*) >
  <!ELEMENT filter (column*) >
  <!ELEMENT column (#PCDATA)>
  <!ATTLIST column name CDATA #REQUIRED
                   subcol CDATA #IMPLIED
                   operator CDATA #IMPLIED
                   value CDATA #IMPLIED >
]>

<!-- Guide to writing rules for distribution:
  The sturcture of this xml document can be understood by the
  Document Type Definition (DTD) given above.

  The root element (distribution-rules) contains 3 node elements which are
  composed of column elements:

    1. select: This contains the columns you want to keep for distribution
               It is required to define this (select) element.
               There must be at least one column definition in it.

    2. drop: This contains the columns you want to drop before distribution
             It is optional to define this element.

    3. filter: This contains the filter rules to be applied on the selected
               columns. It is optional to define this element.

  NOTE:
    1. The order of parsing is select -> drop -> filter.
       i.e The columns selected in 'select' will be dropped if are defined in
       'drop'

    2. If a column's attribute 'subcol' is missing all the subcolumns under it
       will be selected / dropped

    3. Rules can only be defined on columns that appear in 'select' and not in
       'drop'

    4. The rules can be of three types depending upon the operator:
       some_column < some_value
       some_column = some_value
       some_column > some_value

       For the above three cases the operator attribute must be
       "&lt;", "=", "&gt;" respectively

       Also note that to compare a column with a string value,
       for e.g. for a filter like simbadType=Star, ensure to enclose the
       string within single quotes (i.e. value="'Star'")

       Examples:
       <column name="candidate" subcol="ra" operator="&lt;" value="11"/>
       <column name="candidate" subcol="magpsf" operator="&gt;" value="15"/>
       <column name="simbadType" operator="=" value="'Star'"/>
-->

<!-- root element -->
<distribution-rules>

  <!-- columns to select for distribution -->
  <select>
    <column name="objectId"/>
    <column name="candid"/>
    <column name="candidate" subcol="pid"/>
    <column name="candidate" subcol="ra"/>
    <column name="candidate" subcol="dec"/>
    <column name="candidate" subcol="magpsf"/>
    <column name="candidate" subcol="sigmapsf"/>
    <column name="candidate" subcol="sgscore1"/>
    <column name="candidate" subcol="xpos"/>
    <column name="candidate" subcol="ypos"/>
    <column name="prv_candidates"/>
    <column name="cross_match_alerts_per_batch"/>
    <column name="status"/>
  </select>

  <!-- columns to drop before distribution -->
  <drop>
    <column name="prv_candidates"/>
  </drop>

  <!-- filters to apply before distribution -->
  <filter>
    <column name="cross_match_alerts_per_batch" operator="=" value="'RRLyr'"/>
  </filter>

</distribution-rules>
```

and register it in the configuration file for this tutorial.
Also set the Kafka topic in the configuration:

```bash
# in conf/fink.conf.tutorial4
DISTRIBUTION_RULES_XML=${FINK_HOME}/conf/distribution-rules_rrlyr.xml
DISTRIBUTION_TOPIC="fink_RRLyr"
```

Then create the Kafka topic "fink_RRLyr":

```bash
# Create a topic
fink_kafka --create-topic fink_RRLyr
```

and launch the distribution module:

```bash
fink start distribute -c conf/fink.conf.tutorial4
```

## Receiving alerts

Finally, you can read published alerts simply using the `distribution_test` and firing a stream of alert:

```bash
fink start distribution_test -c conf/fink.conf.tutorial4

fink start simulator -c conf/fink.conf.tutorial4
```

you should see alerts coming to your console!

```bash
Batch: 1
-------------------------------------------
+------------+------------------+----------------------------+-------------+------------+-------------+----------------+------------------+------------------+--------------+--------------+
|    objectId|            candid|cross_match_alerts_per_batch|candidate_pid|candidate_ra|candidate_dec|candidate_magpsf|candidate_sigmapsf|candidate_sgscore1|candidate_xpos|candidate_ypos|
+------------+------------------+----------------------------+-------------+------------+-------------+----------------+------------------+------------------+--------------+--------------+
|ZTF17aabuwws|697252840615015002|                       RRLyr| 697252840615|  12.5901418|  -13.2635671|       17.522726|       0.057127114|          0.975042|     2111.8171|     1969.6313|
|ZTF17aacmxco|697252384615010003|                       RRLyr| 697252384615|  12.0926934|  -16.5006772|       16.622976|        0.04782733|          0.994583|      2709.875|     1606.9048|
|ZTF18abomhfb|697252845215010000|                       RRLyr| 697252845215|  13.4967827|   -6.2207403|       17.747196|        0.08618406|          0.991042|     1952.7511|       443.525|
|ZTF18abomhfd|697252845215015003|                       RRLyr| 697252845215|  13.6041884|   -6.4889285|       18.477196|         0.0998575|               1.0|     1574.6538|       1397.36|
|ZTF18abscgig|697252842815015005|                       RRLyr| 697252842815|  10.1513607|  -10.3180915|       17.418629|       0.053634793|              0.99|      496.2473|     1409.0757|
|ZTF18abvetqi|697251924815010000|                       RRLyr| 697251924815|  27.0731769|  -20.5352633|       16.319065|        0.08220117|          0.977917|      522.8542|      323.3284|
+------------+------------------+----------------------------+-------------+------------+-------------+----------------+------------------+------------------+--------------+--------------+

-------------------------------------------
Batch: 2
-------------------------------------------
+------------+------------------+----------------------------+-------------+------------+-------------+----------------+------------------+------------------+--------------+--------------+
|    objectId|            candid|cross_match_alerts_per_batch|candidate_pid|candidate_ra|candidate_dec|candidate_magpsf|candidate_sigmapsf|candidate_sgscore1|candidate_xpos|candidate_ypos|
+------------+------------------+----------------------------+-------------+------------+-------------+----------------+------------------+------------------+--------------+--------------+
|ZTF18abomhce|697252843315015001|                       RRLyr| 697252843315|  14.7483349|   -8.1481062|       18.281933|        0.08949222|               1.0|     1095.4298|      518.3077|
|ZTF18abpcuji|697252383715015006|                       RRLyr| 697252383715|  15.9918596|  -15.6061025|       16.524786|        0.04760386|               1.0|     2592.0396|     1411.4147|
|ZTF18abshksq|697252841415010000|                       RRLyr| 697252841415|   8.8141708|  -12.7276091|       17.599586|        0.07282244|               1.0|     2013.5485|       127.911|
|ZTF18abwpsuu|697251921115010007|                       RRLyr| 697251921115|   23.062596|  -27.7120427|       18.051065|         0.0943352|          0.996667|      654.3224|     2145.2178|
+------------+------------------+----------------------------+-------------+------------+-------------+----------------+------------------+------------------+--------------+--------------+

```
