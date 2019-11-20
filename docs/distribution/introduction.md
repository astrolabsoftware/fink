# Redistributing alerts using Kafka

**Distribution**: [![pypi](https://img.shields.io/pypi/v/fink-filters.svg)](https://pypi.python.org/pypi/fink-filters)

## What is a filter, a topic?

Each night, telescopes are sending raw alerts and the broker enriches these alerts by adding new information to identify interesting candidates for follow-up observations or further scientific processing. The raw stream volume is huge, and each user might want to focus only on a subset of the stream. Hence the output of the broker contains filters that flag only particular parts of the stream to be distributed.

Each stream subset from a particular filter is identified by a topic (ID). This stream can be accessed outside via its topic, and several users can poll the data from the same topic (see [how to collect alerts](communication.md)).

Note that if the filters reduce the size of the stream, they do not filter the content of alerts (i.e. you will receive the full information of alerts distributed).

## How to include your filter in Fink?

In Fink, the distribution is provided by the broker filtering services. A filter is typically a Python routine that selects which alerts need to be sent based on user-defined criteria. Criteria are based on the alert entries: position, flux, properties, ... You can find what is available in ZTF raw alerts [here](../science/ztf_alerts.md), and Fink added values [here](../science/added_values.md).

Let [us](mailto:peloton@lal.in2p3.fr,emilleishida@gmail.com,anais.moller@clermont.in2p3.fr) know about your interest to access particular part of the stream! If you already have a working filter, we would be super happy to make the integration within the broker, otherwise we will design it together. The procedure is described in the [fink-filters](https://github.com/astrolabsoftware/fink-filters) repository or you can follow the [tutorial](../tutorials/create-filters.md) on creating filters. To help the design, you can find what information is available in an alert [here](ztf_alerts.md). Keep in mind, the criteria for acceptance are:

* The filter works ;-)
* The volume of data to be transferred is tractable on our side.

LSST incoming stream is 10 million alerts per night, or ~1TB/night. Hence your filter must focus on a specific aspect of the stream, to reduce the outgoing volume of alerts. Based on your submission, we will provide estimate of the volume to be transferred.
