# Science in Fink

**Science**: [![pypi](https://img.shields.io/pypi/v/fink-science.svg)](https://pypi.python.org/pypi/fink-science) [![Build Status](https://travis-ci.org/astrolabsoftware/fink-science.svg?branch=master)](https://travis-ci.org/astrolabsoftware/fink-science) [![codecov](https://codecov.io/gh/astrolabsoftware/fink-science/branch/master/graph/badge.svg)](https://codecov.io/gh/astrolabsoftware/fink-science)

## What is a scientific added value?

Each night, telescopes are sending raw alerts, with minimal information such as sky location, flux of the transient, and sometimes historical data at this location. The main role of brokers is to enrich these alerts by adding new information to identify interesting candidates for follow-up observations or further scientific processing.

In Fink, the information is provided by the broker services (e.g. identification from the CDS cross-match service) and by user-defined science modules (e.g. machine learning classification, or feature extraction algorithms).

## Fink science cases

In Fink, we mainly focus on 4 science cases, namely we have experts onboard on:

* Detection of supernovae: Ia, but not only!
* Multi-messenger astronomy: Gamma Ray Bursts, gamma ray, X, gravitational waves, neutrino, ...
* Study of micro-lensing: compact objects, exoplanets, ...
* Anomaly detection: unravelling the unknown

There are several modules under construction to probe these science cases, to annotate and flag potential sky alerts that need further attention or inspection.

We are open to contributions in those science cases, but also to new contributions that are not listed here. If you have a science proposal and you would like to integrate it with the broker, contact [us](mailto:contact@fink-broker.org).

## ZTF alert stream

To design the broker and test the science modules while waiting for LSST data, we use the [ZTF](https://www.ztf.caltech.edu/) alert stream. The ZTF alert data (full, unfiltered, 5-sigma alert stream) is publicly available through their [web portal](https://ztf.uw.edu/alerts/public/), and you can find all information about ZTF alerts [here](https://zwickytransientfacility.github.io/ztf-avro-alert/).

## How to include your science case in Fink?

First let [us](mailto:contact@fink-broker.org) know about your science proposal! If you already have a working scientific module, we would be super happy to make the integration within the broker, otherwise we will design it together. The procedure is described in the [fink-science](https://github.com/astrolabsoftware/fink-science) repository or you can follow the [tutorial](../tutorials/create-science-module.md) on creating a science module. Keep in mind, the criteria for acceptance are:

* The science module works ;-)
* The execution time is not too long.

We want to process data as fast as possible, and long running times add delay for further follow-up observations. What execution time is acceptable? It depends, but in any case communicate early the extra time overhead, and we can have a look together on how to speed-up the process if needed.
