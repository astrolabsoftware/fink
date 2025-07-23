# Fink client

The [fink-client](https://github.com/astrolabsoftware/fink-client) is a thin wrapper around low level functionalities in Apache Kafka. The idea is to make stream consuming easy within Fink without the need to develop extra piece of code. 

The fink-client is used in the context of 3 services: Livestream, Data Transfer, and Xmatch. This page explains how to install the client on a computer. 

## Installation of fink-client

`fink_client` requires a version of Python 3.9+.

### Install with pip

From a terminal, you can install fink-client simply using `pip`:

```bash
pip install fink-client --upgrade
```

### Use or develop in a controlled environment

For development, we recommend the use of a virtual environment:

```bash
git clone https://github.com/astrolabsoftware/fink-client.git
cd fink-client
python -m venv .fc_env
source .fc_env/bin/activate
pip install -r requirements.txt
pip install .
```

## Registering

In order to connect and poll alerts from Fink, you first need to get your credentials. Subscribe by filling this [form](https://forms.gle/2td4jysT4e9pkf889) (same than for the livestream service -- so you do not need to it twice). After filling the form, we will send your credentials. Register them on your laptop by simply running on a terminal:

```bash
# access help using `fink_client_register -h`
fink_client_register \
    -username <USERNAME> \ # given privately
    -group_id <GROUP_ID> \ # given privately
    -mytopics <topic1 topic2 etc> \ # see https://fink-broker.readthedocs.io/en/latest/science/filters/
    -servers kafka-ztf.fink-broker.org:24499 \
    -maxtimeout 10 \ # in seconds
     --verbose
```

where `<USERNAME>` and `<GROUP_ID>` have been sent to you privately. By default, the credentials are installed in the home:

```bash
cat ~/.finkclient/credentials.yml
```

## Available tools

Depending on the service you are using, you will use a different tool to retrieve your data from the Fink Kafka cluster:

- The `Livestream` service relies on `fink_consumer`
- The `Data Transfer` service relies on `fink_datatransfer`
- The `Xmatch` service relies on `fink_datatransfer` as well.

For each tool, you can access its documentation by using the `-h` option:

```bash
$ fink_consumer -h
usage: fink_consumer [-h] [--display] [--display_statistics] [-limit LIMIT]
                     [--available_topics] [--save] [-outdir OUTDIR]
                     [-schema SCHEMA] [--dump_schema] [-start_at START_AT]

Kafka consumer to listen and archive Fink streams from the Livestream service

options:
  -h, --help            show this help message and exit
  --display             If specified, print on screen information about incoming
                        alert.
  --display_statistics  If specified, print on screen information about queues,
                        and exit.
  -limit LIMIT          If specified, download only `limit` alerts. Default is
                        None.
  --available_topics    If specified, print on screen information about
                        available topics.
  --save                If specified, save alert data on disk (Avro). See also
                        -outdir.
  -outdir OUTDIR        Folder to store incoming alerts if --save is set. It
                        must exist.
  -schema SCHEMA        Avro schema to decode the incoming alerts. Default is
                        None (version taken from each alert)
  --dump_schema         If specified, save the schema on disk (json file)
  -start_at START_AT    If specified, reset offsets to 0 (`earliest`) or empty
                        queue (`latest`).
```
