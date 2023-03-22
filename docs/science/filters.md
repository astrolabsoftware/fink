# Fink filters

Each night, telescopes are sending raw alerts and the broker enriches these alerts by adding new information to identify interesting candidates for follow-up observations or further scientific processing. The raw incoming stream volume is huge, and each user might want to focus only on a subset of the stream. Hence the output of the broker contains filters that flag only particular parts of the stream to be distributed. Criteria are based on the [alert entries](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html): position, flux, properties, ... and [Fink added values](../science/added_values.md) as filters act after science modules are applied.


![Screenshot](../img/fink-filters.png)

Note that if the filters reduce the size of the stream, they do not filter the content of alerts, i.e. you will receive the full information of alerts distributed.

## Available topics

Each stream subset from a particular filter is identified by a topic name. This stream can be accessed outside via its topic, and several users can poll the data from the same topic (see [fink-client](https://github.com/astrolabsoftware/fink-client)).

Below we summarise the default Fink topics:

| Name | Link | Contents | Status |
|:--------|:-------|:--------|:--------|
| `fink_early_sn_candidates_ztf` | [early_sn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_early_sn_candidates/filter.py) | Return alerts considered as Early SN-Ia candidates. The data from this topic is pushed to TNS every night. | deployed |
| `fink_sn_candidates_ztf` | [sn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_sn_candidates/filter.py) | Return alerts considered as SN candidates | deployed |
| `fink_sso_ztf_candidates_ztf` | [sso_ztf_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_sso_ztf_candidates/filter.py) | Return alerts with a counterpart in the Minor Planet Center database (Solar System Objects) | deployed |
| `fink_sso_fink_candidates_ztf` | [sso_fink_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_fink_ztf_candidates/filter.py) | Return alerts considered as new Solar System Object candidates | deployed |
| `fink_kn_candidates_ztf` | [kn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_kn_candidates/filter.py) | Return alerts considered as Kilonova candidates based on Machine Learning | deployed |
| `fink_early_kn_candidates_ztf` | [early_kn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_early_kn_candidates/filter.py) | Return alerts considered as Kilonova candidates based on crossmatch and property cuts | deployed |
| `fink_rate_based_kn_candidates_ztf` | [rate_based_kn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_rate_based_kn_candidates/filter.py) | Return alerts considered as Kilonova candidates following Andreoni et al. 2021 (https://arxiv.org/abs/2104.06352) | deployed |
| `fink_microlensing_candidates_ztf` | [microlensing_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_microlensing_candidates/filter.py) | Return alerts considered as microlensing candidates | deployed |
| `fink_simbad_ztf` | [simbad](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_simbad_candidates/filter.py) | Return all alerts with a counterpart in the SIMBAD database. See left column of http://simbad.u-strasbg.fr/simbad/sim-display?data=otypes for more information | available on demand |
| `fink_<single-simbad-type>_ztf` | Example [rrlyr](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_rrlyr/filter.py) | Return alerts matching one specific type in the SIMBAD database. See left column of http://simbad.u-strasbg.fr/simbad/sim-display?data=otypes for more information | available on demand |

We also have many internal ones focusing on specific parts of the stream. Feel free also to propose new topics! The topic data is stored for 4 days after creation (i.e. you can access alert data up to 4 days after it has been emitted).

## Create your filter for ZTF

This tutorial goes step-by-step for creating a filters used to define which information will be sent to you by the broker. Running entirely Fink just for testing a filter might be an overwhelming task. Fink can be a complex system, but hopefully it is highly modular such that you do not need all the parts to test one part in particular. In principle, to test a filter you only need Apache Spark installed, and processed data by Fink. Spark API exposes nearly the same methods for static or streaming DataFrame. Hence, to avoid complication due to streaming (e.g. creating streams with Kafka, reading streams, managing offsets, etc...), it is always best to prototype on static DataFrame. If the logic works for static, it will work for streaming.

### Set up your development environment

First make sure you are working in the correct environment. You can either use the Fink Docker images:

```bash
# pull and run the image used for ZTF processing
docker run -t -i --rm julienpeloton/fink-ci:prod bash
```

The advantage of this method is that you have everything installed in it (Python and various frameworks). Alternatively, you can install everything on your machine. For Python packages, just use a virtual environment:

```bash
conda create -n fink-env python=3.9
BASEURL=https://raw.githubusercontent.com/astrolabsoftware/fink-broker/master/deps
pip install -r $BASEURL/requirements.txt
pip install -r $BASEURL/requirements-science.txt
pip install -r $BASEURL/requirements-science-no-deps.txt
```

Then you need to install Apache Spark. If you opted for the Docker version, it is already installed for you. Otherwise just execute:

```bash
SPARK_VERSION=3.1.3
wget --quiet https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-${HADOOP_VERSION}.tgz
tar -xf spark-${SPARK_VERSION}-bin-${HADOOP_VERSION}.tgz
rm spark-${SPARK_VERSION}-bin-${HADOOP_VERSION}.tgz
```

and put these lines in your `~/.bash_profile`:

```bash
export SPARK_HOME=/path/to/spark-${SPARK_VERSION}-bin-${HADOOP_VERSION}
export PATH=$PATH:$SPARK_HOME/bin
export PYTHONPATH=$PYTHONPATH:$SPARK_HOME/python
```

Fork and clone the [fink-filters](https://github.com/astrolabsoftware/fink-filters) repository, and create a new folder in `fink_filters`. The name of the new folder does not matter much, but try to make it meaningful as much as possible!

## Define your filter

A filter is typically a Python routine that selects which alerts need to be sent based on user-defined criteria. Criteria are based on the alert entries: position, flux, properties, ... plus all the added-values from the Fink science modules. A full example can be found at [https://github.com/astrolabsoftware/fink-filters/tree/master/tutorial](https://github.com/astrolabsoftware/fink-filters/tree/master/tutorial) where we focus on alerts with a counterpart in the SIMBAD database and a magnitude above 20.5.

To test your filter, you need some real data to play with. For this, you can use the Data Transfer service (a few nights are usually enough to prototype): [https://fink-portal.org/download](https://fink-portal.org/download).

### Submit your science module

Once your filter is done, open a Pull Request on the fink-filters repository on GitHub, and we will review it and test it extensively before deployment. The criteria for acceptance are:

- The filter works ;-)
- The volume of data to be transferred is tractable on our side.

Keep in mind, LSST incoming stream is 10 million alerts per night, or ~1TB/night. Hence your filter must focus on a specific aspect of the stream, to reduce the outgoing volume of alerts. Based on your submission, we will also provide estimate of the volume to be transferred.

## Step 4: Play!

If your filter is accepted, it will be plugged in the broker, and you will be able to receive your alerts in real-time using the [fink-client](https://github.com/astrolabsoftware/fink-client).
