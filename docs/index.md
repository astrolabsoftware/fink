# Fink documentation

Better than a long speech, here is a list of common questions you might have about Fink!

- **Where is the official Fink website?**
    - [https://fink-broker.org](https://fink-broker.org)
- **What is Fink?**
    - Fink is an alert broker, that is a layer between alert issuers and the scientific community analysing the alert data. It exposes services to help the scientists to efficiently analyse the alert data from telescopes and surveys. Among several, it collects and stores alert data, enriches them with information from other surveys and catalogues or user-defined added values such as machine-learning classification scores, and redistributes the most promising events for further analyses, including follow-up observations.
- **What are Fink goals?**
    - Fink's main scientific objective is to optimize the scientific impact of the Rubin alert data stream. We do not limit ourselves to a specific area, but instead our ambition is to study the transient and variable sky as a whole, from Solar system objects to galactic and extragalactic science. In practice thanks to the Zwicky Transient Facility alert stream, we are already active since 2019 on Solar system objects, young stellar objects, microlensing, supernovae, kilonovae, gamma-ray bursts, active galactic nuclei, and even anomaly detection. On the technological side, Fink aims at providing a robust infrastructure and state-of-the-art streaming services to Rubin scientists, to seamlessly enable user-defined science cases in a big data context.
- **What is the technology behind Fink?**
    - Driven by large-scale optical surveys such as the Zwicky Transient Facility and Rubin Observatory, Fink operates on large cloud infrastructures, and it is based on the [Apache Spark](http://spark.apache.org/) framework. More specifically it uses the [Structured Streaming processing engine](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html). The language chosen for the API is Python, which is widely used in the astronomy community, has a large scientific ecosystem and easily connects with existing tools.
- **How Fink is different from other Rubin Community brokers?**
    - Although Fink has many common features with other Rubin Community brokers, it is community-driven, fully open-source and includes latest big data and machine learning developments.
- **How to join Fink?**
    - The collaboration is currently under a more formal construction, and there are rooms for everybody! You can join using this [form](https://forms.gle/CmvH8vsyyv4AUTpy8), or alternatively contact us at contact(at)fink-broker.org, and we will get in touch with you.
- **How to propose an idea?**
    - Whether you have a concrete plan or you want to brainstorm, feel free you contact us at contact(at)fink-broker.org, and we will get in touch with you.
- **How to learn about all the services deployed by Fink?**
    - You can read about all the services in this documentation website in the section [Services](services.md), including tutorials.
- **How to access the Science Portal and browse Fink processed data?**
    - The Science Portal is accessible at [https://fink-portal.org](https://fink-portal.org)
- **Can Fink do everything I want?**
    - Although many analyses can be performed end-to-end within Fink, we do not always provide everything required to perform a complete analysis as it is sometimes beyond our expertise or our roadmap, or it would require a substantial amount of work to integrate, or simply because some external data requires proprietary access that we do not have. Instead, we expose interoperable tools so that you can export enriched data elsewhere to continue the analysis. In practice, this is where [TOMs](https://lco.global/tomtoolkit/) and Marshals (e.g. [SkyPortal](https://skyportal.io/)), for which interfaces with most brokers have been developed, come in, where the coordination of follow-up observations and further scientific analyses will take place after we enrich the data.
- **How to contribute to Fink?**
    - We welcome scientific and technological contributions as we want Fink to be community-driven. Let's mention also Fink is completely open-source, and we welcome contributors! Make sure you read the [guidelines](contributing.md) first.