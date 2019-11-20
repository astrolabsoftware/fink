# Fink tutorials

This series of tutorials will teach you how to use the broker or how to contribute. They are designed for beginners/intermediate users, but do not hesitate to raise an issue if they are not clear enough.

For all the tutorials, you would need:

* python 3.6+ installed
* Fink's package dependencies installed (see the requirements.txt in each repo)

## Install Apache Spark

In addition, if you want to deep test your developments (all but fink-client), you would need to install Apache Spark. No panic, this is (super) straightforward.

**Download Apache Spark**

Go to their [download](http://spark.apache.org/downloads.html) page, and choose a version 2.4+ (~200MB). Move the archive in a safe place in your computer, and untar it.
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
