# Fink documentation

Better than a long speech, here is a list of common questions you may have about Fink!

- **Where is the official Fink website?**
    - [https://fink-broker.org](https://fink-broker.org)
- **What is Fink?**
    - Fink is an alert broker that serves as an intermediary between alert issuers and the scientific community analyzing the alert data. It provides services designed to assist scientists in efficiently analyzing alert data from telescopes and surveys. Among its various functions, Fink collects and stores alert data, enriches it with information from other surveys and catalogs, as well as user-defined enhancements like machine-learning classification scores. Additionally, it redistributes the most promising events for further analysis, including follow-up observations. 
- **What are Fink goals?**
    - Fink's primary scientific goal is to maximize the scientific impact of the Rubin alert data stream. Rather than focusing on a specific area, our ambition is to explore the transient and variable sky as a whole, encompassing everything from Solar system objects to galactic and extragalactic phenomena. In practice, we have been active since 2019, leveraging the Zwicky Transient Facility alert stream to study a wide range of topics, including Solar system objects, young stellar objects, microlensing, supernovae, kilonovae, gamma-ray bursts, active galactic nuclei, and even anomaly detection. On the technological front, Fink is dedicated to providing a robust infrastructure and cutting-edge streaming services for Rubin scientists, enabling seamless user-defined science cases within a big data context. 
- **What is the technology behind Fink?**
    - Driven by large-scale optical surveys such as the Zwicky Transient Facility and Rubin Observatory, Fink operates on large cloud infrastructures, and it is based on several established bricks such as [Apache Spark](http://spark.apache.org/), [Apache Kafka](https://kafka.apache.org/) and [Apache HBase](https://hbase.apache.org/). The language chosen for most APIs is Python, which is widely used in the astronomy community, has a large scientific ecosystem and easily connects with existing tools.
- **How Fink is different from other Rubin Community brokers?**
    - Although Fink has many common features with other Rubin Community brokers, it is community-driven, fully open-source and it includes latest big data and machine learning developments.
- **How to join Fink?**
    - There are rooms for everybody! You can join using this [form](https://forms.gle/CmvH8vsyyv4AUTpy8), or alternatively contact us at contact(at)fink-broker.org, and we will get in touch with you.
- **How to propose an idea?**
    - Whether you have a concrete plan or you want to brainstorm, feel free to contact us at contact(at)fink-broker.org, and we will get in touch with you.
- **How to learn about all the services deployed by Fink?**
    - You can read about all the services in this documentation website in the section [Services](services.md), including tutorials.
- **How to access the Science Portal and browse Fink processed data?**
    - The Science Portal is accessible at [https://fink-portal.org](https://fink-portal.org)
- **Can Fink do everything I want?**
    - While many analyses can be conducted end-to-end within Fink, we do not always provide all the necessary components for a complete analysis. This may be due to limitations in our expertise or roadmap, the substantial effort required for integration, or the need for proprietary access to certain external data that we do not possess. Instead, we offer interoperable tools that allow you to export enriched data for further analysis elsewhere. In practice, this is where [TOMs](https://lco.global/tomtoolkit/) and Marshals, such as [SkyPortal](https://skyportal.io/), come into play. These tools, which have interfaces developed for most brokers, facilitate the coordination of follow-up observations and additional scientific analyses after we enrich the data. 
- **How to contribute to Fink?**
    - We encourage scientific and technological contributions, as we aim for Fink to be a community-driven initiative. Additionally, Fink is entirely open-source, and we welcome contributors! Please be sure to read the [guidelines](contributing.md) before getting involved.
- **I am writing a paper that utilizes Fink (data, services, ...). How can I acknowledge it?**
    - Thank you for asking the question! You can cite [Möller et al 2021](https://doi.org/10.1093/mnras/staa3602) if wish, and/or include the following in the acknowledgment section: _This work was developed within the Fink community and made use of the Fink community broker resources._
