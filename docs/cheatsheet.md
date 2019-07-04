## Fink broker main commands

### Fink broker pipeline

```bash
#!/bin/bash
set -e

# Check if HBase service is running
HBASE_ACTIVATED=`ps aux | grep hbase| grep -v grep | wc -l`

if (( $HBASE_ACTIVATED == 0 )); then
 echo -e "You need to activate HBase first"
 exit 1
fi

# Select a configuration file
CONF=conf/fink.conf

# Redirect (driver) logs here
mkdir -p logs

# stream to raw DB
fink start stream2raw -c $CONF --simulator > logs/stream2raw.log &

sleep 5

# raw DB to science DB (incl. filtering and processing)
fink start raw2science -c $CONF --simulator > logs/raw2science.log &

sleep 5

# Start kafka cluster for redirection
fink_kafka start

# Create fake topic for redistribution
fink_kafka --create-topic my_favourite_topic

# Redistribute data (incl. filtering)
fink start distribution -c $CONF > logs/distribution.log &

sleep 5

# Read redistributed data to check it works
# Make sure you are using the same topic as was defined above
fink start distribution_test -c $CONF
```

### Launching alerts (locally)

```bash
# Make sure you use the same configuration to read the stream
fink start simulator -c conf/fink.conf
```

### Fink shell

```bash
# Default is pyspark shell with ipython as driver
fink_shell -c conf/fink.conf.shell
```

### Testing Fink

```bash
fink_test
```

###
