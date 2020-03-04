# Fink client

[fink client](https://github.com/astrolabsoftware/fink-client) is a light package to manipulate catalogs and alerts issued from the [fink broker](https://github.com/astrolabsoftware/fink-broker) programmatically.

## Fink's distribution stream

Fink distributes alerts via Kafka topics based on one or several of the alert properties (label, classification, flux, ...). Topics are created via user-defined filters (see [available topics](topics.md)). You can connect to existing stream, and if you would like to create a new stream, follow the [tutorial](tutorials/create-filters.md) or raise a new issue in [fink-filters](https://github.com/astrolabsoftware/fink-filters) describing the alert properties and thresholds of interest.

You can connect to one or more of these topics using fink-client's APIs and receive Fink's stream of alerts. To obtain security credentials for API access and authorization on kafka topics, you need to [subscribe](https://forms.gle/2td4jysT4e9pkf889).

## Tutorial

In order to familiarise with the client, we invite users to follow the dedicated tutorial: https://github.com/astrolabsoftware/fink-tutorials. Note that you need your credentials to play the tutorial.
