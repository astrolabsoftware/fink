# Fink tutorials

### How to use Fink REST API (beginners & advanced)

- REST API documentation: [link](https://fink-portal.org/api)
- REST API tutorials: [link](https://github.com/astrolabsoftware/fink-notebook-template)

The Science Portal ([https://fink-portal.org](https://fink-portal.org)) is a web application that allows users to browse and query all Fink processed data. It uses the REST API in the background. The portal carries it own documentation.

### How to use the livestream service

- livestream service: [link](https://github.com/astrolabsoftware/fink-client/blob/master/docs/livestream_manual.md)

### How to use the broker (advanced)

This series of tutorials will teach you how to use the broker or how to contribute. They are designed for beginners/intermediate users, but do not hesitate to raise an issue if they are not clear enough.

* Simulate incoming alert streams to feed Fink: [tutorial 1](simulator.md)
* Deploy an instance of the Fink broker: [tutorial 2](deployment.md)
* Create and integrate your science module: [tutorial 3](create-science-module.md) (or [alternative](https://github.com/astrolabsoftware/fink-science/tree/master/tutorial))
* Create and integrate your filter: [tutorial 4](create-filters.md) (or [alternative](https://github.com/astrolabsoftware/fink-client/blob/master/docs/create_filter.md))
* Explore the Fink databases: [tutorial 5](db-inspection.md)

For all the tutorials, you need:

* Python 3.6+ installed
* fink-broker installed (see [Local use](../broker/introduction.md#installation-local-mode))
* Fink's package dependencies installed (see the requirements.txt in each repo)

or you can directly use the docker image provided in the repository (see [docker use](../broker/introduction.md#use-with-docker)).

### Misc

- Manipulate fake streams: [link](https://github.com/astrolabsoftware/fink-client/tree/master/tests)

## Install Apache Spark on your machine

In addition, if you want to deep test your developments in your local machine, you would need to install Apache Spark. No panic, this is (super) straightforward.

**Download Apache Spark**

Go to their [download](http://spark.apache.org/downloads.html) page, and choose a version 2.4+ (~200MB), but not versions 3.x. Move the archive in a safe place in your computer, and untar it.
Make a symbolic link on the resulting folder:

```bash
ln -s spark-2.X.X-bin-hadoopX.X spark
```

*Optional: download java 8*

Apache Spark needs Java 8. In case you do not have it, install it and link it in your `~/.bash_profile`:

```bash
# To see different java jdk: /usr/libexec/java_home -V
# and then set the version 8
export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0_151`
```

**Link Apache Spark**

In your `~/.bash_profile`, add the following lines:

```bash
export SPARK_HOME=/path/to/spark
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

export SPARKLIB=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
export PYTHONPATH="$SPARKLIB:$PYTHONPATH"
```

**Test Apache Spark**

Execute `pyspark`. If you end up with a python shell decorated with Spark verbosity, you won! Otherwise... feel free to contact us!
