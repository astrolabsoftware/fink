# Tutorial: Working on Secured Kafka Cluster

**Context**

This tutorial illustrates the basics of working with a secured Kafka Cluster. It will show
how to authenticate clients and authorize for role of producer / consumer.

**Before starting**

For this tutorial, make sure:

* Fink is installed on your computer.
* Apache Kafka is installed on your computer.

See [Tutorial 4](redistributing_alerts.md) for more details on working with Fink's redistribution,

The security measures used for Fink's Kafka Cluster are:

1. Authentication using SASL/SCRAM-SHA-512
2. Authorization using ACLs

See [Security](../user_guide/streaming-out.md#security) for more details.

**Example**

Let us walk through a simple example:

**Bob** wants to send messages on topic `test_topic` and **Alice** wants to consume messages from `test_topic`.

The process is as follows:

Start the Kafka Cluster
```bash
fink_kafka start
```

Create the topic `test_topic`
```bash
fink_kafka --create-topic test_topic
```

### Authentication

Credentials for Authentication can be added / removed using `fink_kafka --authentication`.
To get he help message, Execute `fink_kafka --authentication -h`:
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

Add SASL/SCRAM credentials for Authentication of Bob and Alice

```bash
fink_kafka --authentication -a -u Bob -p Bob-secret
fink_kafka --authentication -a -u Alice -p Alice-secret
```

### Authorization

ACLs which are stored in Zookeeper can be modified (add / remove) using `fink_kafka --authorization`.
To get the help message, Execute `fink_kafka --authorization -h`:
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

Authorize Bob as a producer for the topic `test_topic`, assuming localhost (`127.0.0.1`):

```bash
fink_kafka --authorization -a -u Bob -H 127.0.0.1 -p -t test_topic
```

Authorize Alice as a consumer with consumer group as `test-group` on the topic `test_topic`, assuming localhost (`127.0.0.1`):

```bash
fink_kafka --authorization -a -u Alice -H 127.0.0.1 -c test-group -t test_topic
```

You must see relevant messages on execution of the above commands.
Now we can test the working of the above Kafka pipeline using simple python applications.

Create a python program to act as the producer (Bob): `securedProducer.py`. Add the following to it:
```python
#!/bin/python3
# A simple Kafka Producer running on a secured Kafka Cluster

import time
from confluent_kafka import Producer

p = Producer({
    'bootstrap.servers': 'localhost:9093',
    'security.protocol': 'sasl_plaintext',
    'sasl.mechanism': 'SCRAM-SHA-512',
    'sasl.username': 'Bob',
    'sasl.password': 'Bob-secret'
})

for i in range(50):
    data = f"Hi from Bob: {i+1}"
    p.produce('test_topic', data.encode('utf-8'))
    time.sleep(1)

p.flush()
```

Create another python program to act as consumer (Alice): `securedConsumer.py`. Add the following to it:
```python
#!/bin/python3
# A simple Kafka Consumer running on a secured Kafka Cluster

from confluent_kafka import Consumer, KafkaError

c = Consumer({
    'bootstrap.servers': 'localhost:9093',
    'group.id': 'test-group',
    'auto.offset.reset': 'earliest',
    'security.protocol': 'sasl_plaintext',
    'sasl.mechanism': 'SCRAM-SHA-512',
    'sasl.username': 'Alice',
    'sasl.password': 'Alice-secret'
})

c.subscribe(['test_topic'])

while True:
    msg = c.poll(1.0)

    if msg is None:
        continue
    if msg.error():
        print("Consumer error: {}".format(msg.error()))
        continue

    print('Received message: {}'.format(msg.value().decode('utf-8')))

c.close()
```
Open a terminal to start the consumer app
```bash
python3 securedConsumer.py
```

In another terminal start the producer app
```bash
python3 securedProducer.py
```
You should see the consumer receiving messages:
```plain
Received message: Hi from Bob: 1
Received message: Hi from Bob: 2
Received message: Hi from Bob: 3
Received message: Hi from Bob: 4
...
```
## Connecting to Fink (WIP)
We are currrently working on developing a client API for securely connecting
to Fink. Such a client API would enable users to subscribe to topics for receiving
Fink's outstream of alerts, search Fink's database and submit queries.
