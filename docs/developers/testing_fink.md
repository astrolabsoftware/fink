## Installation and general tests (experts only)

Installing Fink is not too complicated but might be an overwhelming task. Fink can be a complex system, but hopefully it is highly modular such that you do not need all the parts to test one part in particular. If you want to test it fully though, we recommend using the available Docker images, which contain all you need to start (Apache Spark, Apache Kafka, Apache HBase, plus Fink components). You can find these either in the [fink-docker](https://github.com/astrolabsoftware/fink-docker) repository (soon deprecated), or in the [fink-broker](https://github.com/astrolabsoftware/fink-broker/blob/master/doc/devel.adoc) repository (kubernetes support as well)


### Running the test suite with Docker

In general, you can follow what is done for the [continuous integration](https://github.com/astrolabsoftware/fink-broker/blob/master/.github/workflows/test.yml). Once the image is pulled, you need to set the `PYTHONPATH` and `PATH` to use the tools:

```bash
# in your ~/.bash_profile
export FINK_HOME=/path/to/fink-broker
export PYTHONPATH=$FINK_HOME:$PYTHONPATH
export PATH=$FINK_HOME/bin:$PATH
```

The fink-broker repository contains some alerts from the ZTF experiment required for the test suite in the folder `datasim`. If you need to download more alerts data, go to the datasim directory and execute the download script:

```bash
cd datasim
./download_ztf_alert_data.sh
cd ..
```

Make sure the test suite is running fine. Just execute:

```bash
fink_test [--without-integration] [-h]
```

You should see plenty of Spark logs (and yet we have shut most of them!), but no failures hopefully! Success is silent, and the coverage is printed on screen at the end. You can disable integration tests by specifying the argument `--without-integration`. Note for docker users: you need to install fink-science and fink-filters (either mounted inside the container, or installed via pip) prior running the test suite. See above for more information.

### Tests with Kubernetes

To come.
