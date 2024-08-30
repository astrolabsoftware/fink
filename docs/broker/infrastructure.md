[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=finkbroker&metric=alert_status)](https://sonarcloud.io/dashboard?id=finkbroker)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=finkbroker&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=finkbroker)
[![Sentinel](https://github.com/astrolabsoftware/fink-broker/workflows/Sentinel/badge.svg)](https://github.com/astrolabsoftware/fink-broker/actions?query=workflow%3ASentinel)
[![PEP8](https://github.com/astrolabsoftware/fink-broker/workflows/PEP8/badge.svg)](https://github.com/astrolabsoftware/fink-broker/actions?query=workflow%3APEP8)
[![codecov](https://codecov.io/gh/astrolabsoftware/fink-broker/branch/master/graph/badge.svg)](https://codecov.io/gh/astrolabsoftware/fink-broker)
# Technological consideration

!!! tip "Technological goal"
	On the technological front, Fink is dedicated to providing a robust infrastructure and cutting-edge streaming services for Rubin scientists, enabling seamless user-defined science cases within a big data context.

![Screenshot](../img/infrastructure.png#only-light)
![Screenshot](../img/infrastructure-alt.png#only-dark)

Driven by large-scale optical surveys such as the Zwicky Transient Facility and Rubin Observatory, Fink operates on large scientific cloud infrastructures (VirtualData at Paris-Saclay, and CC-IN2P3), and it is based on several established bricks such as [Apache Spark](http://spark.apache.org/), [Apache Kafka](https://kafka.apache.org/) and [Apache HBase](https://hbase.apache.org/). 
!!! info "Programming languages"
	The primary language chosen for most APIs is Python, which is widely used in the astronomy community, has a large scientific ecosystem, and easily integrates with existing tools. However, under the hood, Fink utilizes several other languages, including Scala, Java, and Rust. Modern codebases often require a variety of programming languages!

Fink is mainly based on the recent [Spark Structured Streaming](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html) module introduced in Spark 2.0 (see [paper](https://cs.stanford.edu/~matei/papers/2018/sigmod_structured_streaming.pdf)), and especially its integration with Apache Kafka (see [here](https://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html)). Structured streaming is a stream processing engine built on the Spark SQL engine, hence it combines the best of the two worlds.
The idea behind it is to process data streams as a series of small batch jobs, called micro-batch processing. As anything in Spark, it provides fast, scalable, fault-tolerant processing, plus end-to-end exactly-once stream processing.

## Broker structure

!!! tip "Fink broker structure"

	The broker is made of 4 modules:

	* **stream2raw**: connect to incoming stream of alerts, and archive data on disk.
	* **raw2science**: filter out bad quality alerts, and add values to remaining alerts using the user-defined science modules.
	* **distribution**: redistribute alerts to users based on user-defined filters (Kafka topics).
	* **archive**: store alerts containing scientific added values.

You can install and test all of these components in local mode, with moderate resources required (see [testing Fink](../developers/testing_fink.md)).

## Can Fink do everything?

While many analyses can be conducted end-to-end within Fink, we do not always provide all the necessary components for a complete analysis. This may be due to limitations in our expertise or roadmap, the substantial effort required for integration, or the need for proprietary access to certain external data that we do not possess. Instead, we offer interoperable tools that allow you to export enriched data for further analysis elsewhere. In practice, this is where plateform such as [AstroColibri](https://astro-colibri.science/), observation managers such as [TOMs](https://lco.global/tomtoolkit/) and marshals such as [SkyPortal](https://skyportal.io/), come into play. These tools, which have interfaces developed for most brokers, facilitate the coordination of follow-up observations and additional scientific analyses after we enrich the data.
