# Collecting Fink alerts

In Fink we distribute alert data in mainly two ways:

* using Apache Kafka
* using VOEvent [Work in progress]

## Fink client [Apache Kafka]

**Client**: [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=astrolabsoftware_fink-client&metric=alert_status)](https://sonarcloud.io/dashboard?id=astrolabsoftware_fink-client) [![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=astrolabsoftware_fink-client&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=astrolabsoftware_fink-client)
[![Build Status](https://travis-ci.org/astrolabsoftware/fink-client.svg?branch=master)](https://travis-ci.org/astrolabsoftware/fink-client)
[![codecov](https://codecov.io/gh/astrolabsoftware/fink-client/branch/master/graph/badge.svg)](https://codecov.io/gh/astrolabsoftware/fink-client)

[fink-client](https://github.com/astrolabsoftware/fink-client) is a light package to manipulate stream of alerts issued from the fink broker programmatically. It is intended primarily to be installed on laptops, for daily analyses.

The package contains a standalone dashboard application, but you can also includes the library in your favourite program to process the alerts. For more information, you can follow the fink-client [tutorial](../tutorials/using-fink-client.md).

## Using VOEvent

To come...
