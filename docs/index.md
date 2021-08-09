# Welcome to <img src="https://fink-broker.readthedocs.io/en/latest/img/Fink_PrimaryLogo_WEB.png" width=150 />'s documentation!

## Overview

Better than a long speech, here is a list of common questions you might have about Fink!

- **What is Fink?**
    - Fink is a broker infrastructure enabling a wide range of applications and services to connect to and scientifically enrich large streams of alerts issued from telescopes all over the world.
- **What are Fink goals?**
    - Fink's main scientific objective is to optimize the scientific impact of Rubin alerts for a set of science cases: supernovae, microlensing, multi-messenger astronomy and anomaly detection. On the technological side, Fink aims at providing a robust infrastructure and state-of-the-art streaming services to Rubin scientists, to seamlessly enable user-defined science cases in a big data context.
- **What is the technology behind Fink?**
    - Fink core is based on the [Apache Spark](http://spark.apache.org/) framework, and more specifically it uses the [Structured Streaming processing engine](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html). The language chosen for the API is Python, which is widely used in the astronomy community, has a large scientific ecosystem and easily connects with existing tools.
- **How Fink is different from other brokers?**
    - Although Fink has many common features with other brokers, it is community-driven, fully open-source and includes latest big data and machine learning developments.
- **How to join Fink?**
    - The collaboration is currently under a more formal construction, and there are rooms for everybody! Contact us at contact(at)fink-broker.org, and we will get in touch with you.
- **Where is the official Fink website?**
    - https://fink-broker.org
- **How to access the Science Portal and browse Fink processed data?**
    - The Science Portal is accessible at http://134.158.75.151:24000/ (We promise that one day we will buy a domain name for this one...)
- **How to receive Fink alerts live?**
    - We have a client ([fink-client](https://github.com/astrolabsoftware/fink-client)) that allows you to connect to and receive Fink processed data. How to install it? `pip install fink-client`! More information, including a tutorial, in the [fink-client](fink-client.md) page.
- **How to contribute to Fink?**
    - We welcome scientific and technological contributions as we want Fink to be community-driven. Let's mention also Fink is completely open-source, and we welcome contributors! Make sure you read the [guidelines](contributing.md) first.

## Getting started

Learning Fink is easy whether you are a developer or a scientist:

* Learn about the [broker technology](broker/introduction.md), the [science](science/introduction.md) we do, and how to [receive](fink-client.md) alerts.
* Learn how to use the broker or how to contribute following the different [tutorials](tutorials/introduction.md).
* Explore the different components:
    * [fink-alert-simulator](https://github.com/astrolabsoftware/fink-alert-simulator): Simulate alert streams for the Fink broker.
    * [fink-broker](https://github.com/astrolabsoftware/fink-broker): Astronomy Broker based on Apache Spark.
    * [fink-science](https://github.com/astrolabsoftware/fink-science): Define your science modules to add values to Fink alerts.
    * [fink-filters](https://github.com/astrolabsoftware/fink-filters): Define your filters to create your alert stream in Fink.
    * [fink-client](https://github.com/astrolabsoftware/fink-client):  Light-weight client to manipulate alerts from Fink.
