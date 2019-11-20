# Connect to Fink streams using fink-client

`fink-client` is a light package to manipulate catalogs and alerts issued from the [fink broker](https://github.com/astrolabsoftware/fink-broker) programmatically.

## Installation

Clone the GitHub repository
```bash
git clone https://github.com/astrolabsoftware/fink-client.git
cd fink-client && export FINK_CLIENT_HOME=$(PWD) >> ~/.bash_profile
```
The above expression will place the environment variable for `$FINK_CLIENT_HOME`
into your `~/.bash_profile` such that this variable should not be required to be set again.

Install `fink_client` and it's dependencies

```bash
pip install --upgrade pip setuptools wheel
pip install -e .
```

Run integration test to verify everything is working properly

```bash
bin/fink_client_test.sh
```

If you don't see any error and all the test results are ok, you have installed it correctly.

*Note:
This is a work in progress and we will soon provide a PyPI based installation.*

## Documentation

**Fink's distribution stream**

Fink distributes alerts via Kafka topics based on one or several of the alert properties (label, classification, flux, ...). Topics are created via user-defined filters (see [distribution](../distribution/introduction.md)). You can connect to existing stream, and if you would like to create a new stream, follow the [tutorial](../tutorials/create-filters.md) or raise a new issue in [fink-filters](https://github.com/astrolabsoftware/fink-filters) describing the alert properties and thresholds of interest.

You can connect to one or more of these topics using fink-client's APIs and receive Fink's stream of alerts. To obtain security credentials for API access and authorization on kafka topics contact Fink's admins.

**Connecting to Fink's stream of alerts**

Once you have the security credentials for accessing the API, import and instantiate an `AlertConsumer`. The mandatory configurations are `topics`, the security credentials (`username` and `password`) and the `group_id` for which read offsets are stored. You can also pass the optional configuration: `bootstrap.servers`. If not given the default fink servers will be used.

```python
from fink_client.consumer import AlertConsumer
topics = ["rrlyr", "ebwuma"]
config = {
  "username": "client_name",
  "password": "********",
  "group_id": "client_group"
}

consumer = AlertConsumer(topics, config)
```
A single alert can be received using the `poll()` method of `AlertConsumer`. The alerts are received as tuple of (topic, alert) of type (str, dict).

```python
ts = 5  # timeout (seconds)
topic, alert = consumer.poll(timeout=ts)

if alert is not None:
    print("topic: ", topic)
    for key, value in alert.items():
        print("key: {}\t value: {}".format(key, value))
else:
    print(f"no alerts received in {ts} seconds")
```

Multiple alerts can be received using the `consume()` method. The method returns a list of tuples (topic, alert) with maximum `num_alerts` number of alerts.

```python
alerts = counsumer.consume(num_alerts=10, timeout=30)

for topic, alert in alerts:
    print("topic: ", topic)
    print("alert:\n", alert)
```

To consume the alerts in real time one can use the `poll` method in a loop:

```python
# receive alerts in a loop
while True:
    topic, alert = consumer.poll(2)
    print("topic: {}, alert:\n {}".format(topic, alert))
```
Make sure you close the connection, or you can also use the context manager:
```python
from fink_client.consumer import AlertConsumer, AlertError
# Close the connection explicitly
consumer = AlertConsumer(topics, config)
try:
    topic, alert = consumer.poll(5)
    print("topic: {}, alert:\n {}".format(topic, alert))
except AlertError as e:
    print(e)
finally:
    consumer.close()

# Or use context manager
with AlertConsumer(topics, config) as consumer:
    topic, alert = consumer.poll(5)
    print("topic: {}, alert:\n {}".format(topic, alert))
```

To learn more about the schema of received alerts and how to work with them, refer to the [jupyter notebook](https://github.com/astrolabsoftware/fink-client/blob/master/notebooks/working_with_alerts.ipynb). (WIP)

## Dashboard

To come...
