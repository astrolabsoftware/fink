# Fink client

[![pypi](https://img.shields.io/pypi/v/fink-client.svg)](https://pypi.python.org/pypi/fink-client) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=astrolabsoftware_fink-client&metric=alert_status)](https://sonarcloud.io/dashboard?id=astrolabsoftware_fink-client) [![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=astrolabsoftware_fink-client&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=astrolabsoftware_fink-client)
[![Build Status](https://travis-ci.org/astrolabsoftware/fink-client.svg?branch=master)](https://travis-ci.org/astrolabsoftware/fink-client)
[![codecov](https://codecov.io/gh/astrolabsoftware/fink-client/branch/master/graph/badge.svg)](https://codecov.io/gh/astrolabsoftware/fink-client)

[fink client](https://github.com/astrolabsoftware/fink-client) is a light package to manipulate catalogs and alerts issued from the [fink broker](https://github.com/astrolabsoftware/fink-broker) programmatically. It is intended primarily to be installed on laptops, for daily analyses.

![Screenshot](../img/output_10_5.png)

## Fink's distribution stream

Fink distributes alerts via [Apache Kafka](https://kafka.apache.org/) topics based on one or several of the alert properties (label, classification, flux, ...). Topics are created via user-defined filters (see [available topics](topics.md)). You can connect to existing streams, and if you would like to create a new stream, follow the [tutorial](https://github.com/astrolabsoftware/fink-client/blob/master/docs/create_filter.md) or raise a new issue in [fink-filters](https://github.com/astrolabsoftware/fink-filters) describing the alert properties and thresholds of interest.

You can connect to one or more of these topics using fink-client's APIs and receive Fink's stream of alerts. The client can easily be installed using pip:

```bash
pip install fink-client
```

In order to connect and poll alerts from Fink, you need to get your credentials:

1. Subscribe to one or more Fink streams by filling this [form](https://forms.gle/2td4jysT4e9pkf889).
2. After filling the form, we will send your credentials. Register them on your laptop by simply running:
  ```
  fink_client_register -username <USERNAME> -group_id <GROUP_ID> ...
  ```

## Tutorial

In order to familiarise with the client, we invite users to follow the dedicated tutorial: [https://github.com/astrolabsoftware/fink-client/tree/master/docs](https://github.com/astrolabsoftware/fink-client/tree/master/docs). Note that you need your credentials to play the tutorial.
