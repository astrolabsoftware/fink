# Explore the Fink databases

This tutorial shows how to connect to the Fink databases, and explore the collected (raw database) and processed alerts (science database).

## Using the Fink shell

The Fink shell is a ipython shell with Apache Spark & Fink integration to manipulate large datasets interactively. You can easily try it out:

```bash
fink_shell -c ${FINK_HOME}/conf/fink.conf.shell
```

Since the databases of Fink are stored in the cloud, we usually increase the resources for the shell:

```bash
# Using YARN for example
SPARK_MASTER=yarn

# Using 3 machines of 17 cores each with 30GB RAM per executor
EXTRA_SPARK_CONFIG="--driver-memory 4g --executor-memory 30g --executor-cores 17 --total-executor-cores 51"
```

Note that you can also use it as a Jupyter notebook by specifying:

```bash
# Pyspark driver: None, Ipython, or Jupyter-notebook
# Note: for Jupyter on a cluster, you might need to specify the options
# --no-browser --port=<PORT>, and perform port redirection when ssh-ing.
PYSPARK_DRIVER_PYTHON=`which jupyter-notebook`
```

## Example 1: checking for cross-match between ZTF and SIMBAD

Load alert data from the raw database (i.e. the database containing all received alerts by the broker)

```python
# The path to the data is $FINK_ALERT_PATH in your config
dfraw = spark.read.format('parquet').load('ztf-simulator/alerts_store')
dfraw.count()
# 148689
```

In this example we have about 150,000 alerts stored (one particular ZTF night). Note that the data is partitioned, and you can filter data by date range if needed to transfer less data (think functional programming). Let's now load the alerts from the scientific database, that is alerts that have been processed and enriched by the broker:

```python
# The path to the data is $FINK_ALERT_PATH_SCI_TMP in your config
dfsci = spark.read.format('parquet').load('ztf-simulator/alerts_store_tmp')
dfsci.count()
# 64501
```
We can see that only 43% of raw alerts entered the scientific pipelines. Others have been flagged out by _quality cuts_. You can inspect alerts by using the `show` method, but unless you know exactly what you want it will not be very telling (more than 60,000 in one night!). Instead let's group alerts by their SIMBAD identification obtained from a cross-match between the stream of alerts and the SIMBAD database (this is performed by one of the Fink module):

```python
# Grouped DataFrame
df_group_per_match = dfsci.select('cdsxmatch').groupby('cdsxmatch').count()
```

This [page](http://simbad.u-strasbg.fr/simbad/sim-display?data=otypes) describes all the possible types. Let's see rare types of alerts (less than 5 alerts identified in a night):

```python
df_group_per_match.filter('count < 5').show()
+---------------+-----+
|      cdsxmatch|count|
+---------------+-----+
|     Erupt*RCrB|    2|
| GravLensSystem|    2|
|  Candidate_Be*|    1|
|            WD*|    3|
|        Planet?|    2|
|             UV|    2|
|       EllipVar|    2|
|            PN?|    1|
|            Ae*|    2|
|       pulsV*SX|    1|
|      Nova-like|    4|
|          Maser|    2|
|Candidate_TTau*|    1|
|           RGB*|    2|
|    HotSubdwarf|    2|
|         Blazar|    1|
|   Irregular_V*|    4|
|          EmObj|    3|
|  AbsLineSystem|    4|
|           Pec*|    1|
+---------------+-----+
only showing top 20 rows
```

You can see many different types, even two possible Extra-solar Planet candidates! Let's have a look at the most common types now (types with more than 100 alerts flagged in a night):

```python
df_group_per_match.filter('count > 100').show()
+------------+-----+
|   cdsxmatch|count|
+------------+-----+
|          V*|  477|
|          C*|  256|
|     EB*WUMa| 1650|
|     Unknown|49844|
|        AGB*|  123|
|Candidate_C*|  103|
|         YSO|  135|
|   Seyfert_1|  244|
|        LPV*|  695|
|         QSO|  510|
|        Star| 3336|
|        Mira|  831|
|         EB*|  179|
|       RRLyr| 4489|
|    EB*Algol|  245|
+------------+-----+
```

and the winner is... `Unknown` (~30% of the incoming alerts, or ~78% of the alerts entering the science pipelines)! That is alerts that do not have counter-part in the SIMBAD database. These are very good candidates for new and unidentified objects, for which we would need further processing.

For a given type, you can also retrieve alerts information. Let's see all the types containing only one alert, and display alert information:

```python
# Take only types with 1 alert candidate
dfone = df_group_per_match.filter(df_group_per_match['count'] == 1)

# Join initial and grouped+filtered dataframes
dfsci_one = dfsci.join(dfone, 'cdsxmatch')

# Show only some properties
dfsci_one.select([
  'objectId',
  'cdsxmatch',
  'candidate.ra',
  'candidate.dec',
  'candidate.magpsf']
).show()
+------------+----------------+-----------+----------+---------+
|    objectId|       cdsxmatch|         ra|       dec|   magpsf|
+------------+----------------+-----------+----------+---------+
|ZTF19aaxozdw|          Blazar| 16.2882729|39.4709933|19.429348|
|ZTF18absduqw|Blazar_Candidate|253.4442088|16.8302361|19.328213|
|ZTF18abahsgn|   Candidate_Be*|285.0898866| 5.3335996|18.096966|
|ZTF19aaocygn| Candidate_TTau*|277.2092642| 0.1636963|19.070953|
|ZTF18aavewqd|             PM*| 301.287262|36.2673115|14.855374|
|ZTF17aaboplx|             PN?|304.6492531|40.9188622|18.560099|
|ZTF18aaowgrl|         PartofG|247.4704751|24.4439163|19.361742|
|ZTF18abosfoe|            Pec*|355.1810384|35.5177032| 16.51896|
|ZTF18aayvzal|             Red|296.0941578|23.7139087|19.115326|
|ZTF18abrrmeg|    RotV*alf2CVn|284.9318893|-3.0933607| 16.46145|
|ZTF18aagrcve|              XB| 235.269441|36.0479687|16.737507|
|ZTF18abgjszd|        pulsV*SX| 289.015307|30.2612346|17.157406|
+------------+----------------+-----------+----------+---------+
```

## Example 2: Checking for supernovae

From `fink-science@0.1.8`, Fink computes the probability of an alert to be a SN Ia. The classification is based on the Machine Learning Random Forest algorithm (see https://arxiv.org/abs/1804.03765), and more details on the implementation can be found [here](https://github.com/astrolabsoftware/fink-science/tree/master/fink_science/random_forest_snia).

Let's load the alerts from the scientific database (4th November 2019), that is alerts that have been processed and enriched by the broker:

```python
# The path to the data is $FINK_ALERT_PATH_SCI_TMP in your config
df = spark.read.format('parquet').load('ztf-simulator/alerts_store_tmp')
df.count()
# 93963
```

We have nearly 100,000 alerts processed and we want to know which ones are good supernova candidates. The classification score `rfscore` is a good indicator, but to increase our confidence we also want to take into account other factors: alerts without close counterpart in Gaia or PS1 (at least 5 arcseconds), without known counterpart in Simbad ('Unknown') and with a non-zero `rfscore` (zero means not enough measurements to perform the fit). All combined, the 100,000 alerts are reduced to 95 alerts! Among those 95, let's take the top 7 in terms of `rfscore`:

```python
from pyspark.sql.functions import asc

fields = [
  'objectId', 'rfscore', 'cdsxmatch',
  'candidate.classtar', 'candidate.neargaia',
  'candidate.distpsnr1'
]

df.select(fields).filter(df['rfscore'] > 0.0)\
  .filter(df['cdsxmatch'] == 'Unknown')\
  .filter(df['candidate.neargaia'] > 5)\
  .filter(df['candidate.distpsnr1'] > 5)\
  .orderBy(asc("rfscore"))\
  .show(7)
+------------+-------+---------+--------+---------+---------+
|    objectId|rfscore|cdsxmatch|classtar| neargaia|distpsnr1|
+------------+-------+---------+--------+---------+---------+
|ZTF19acgjohb|  0.276|  Unknown|   0.982|56.919067|21.207327|
|ZTF19acdytef|  0.303|  Unknown|   0.977|5.6352506|5.6259537|
|ZTF18aaznglt|   0.31|  Unknown|   0.973|5.8049145|  5.81257|
|ZTF19abdkgwo|  0.318|  Unknown|   0.981|10.498369|10.511302|
|ZTF18abilnyi|  0.346|  Unknown|   0.802|51.238014|11.833536|
|ZTF19acftude|  0.354|  Unknown|   0.983|12.321621| 6.009926|
|ZTF19acetxvq|  0.359|  Unknown|   0.983|23.463406| 5.048062|
+------------+-------+---------+--------+---------+---------+
only showing top 7 rows
```

In this run, the `rfscore` should be read `1 - rfscore` (just a convention bug), hence the lower the more probable to be a SN Ia. Among the list above:
- ZTF19acgjohb (1st): SN Ia ([TNS](https://wis-tns.weizmann.ac.il/object/2019tjc), [Lasair](https://lasair.roe.ac.uk/object/ZTF19acgjohb))
- ZTF19abdkgwo (4th): SN II ([TNS](https://wis-tns.weizmann.ac.il/object/2019khb), [Lasair](https://lasair.roe.ac.uk/object/ZTF19abdkgwo/))
- ZTF19acetxvq (6th): SN IIn ([TNS](https://wis-tns.weizmann.ac.il/object/2019sxv), [Lasair](https://lasair.roe.ac.uk/object/ZTF19acftude/))
- ZTF19acetxvq (7th): SN Ia ([TNS](https://wis-tns.weizmann.ac.il/object/2019soh), [Lasair](https://lasair.roe.ac.uk/object/ZTF19acetxvq/))

The others have been classified as orphans SN. Not bad! Note that the model used to train the algorithm is not very powerful due to lack of good input data (hence the score are not so good). We expect to get even better scores once retrained with more realistic alert data.

## Example 3: Forecasting the yield of a science filter

Often you want to know the yield of a filter (current or new one), that is the percentage of alerts flagged by a particular filter (in Fink, filters are used to redistribute streams based on user-defined criteria). You can simply do it by comparing the raw database (containing all incoming alerts) and the science database (containing scientifically enriched alerts):

```python
# Load the filter that you want to inspect
from fink_filters.filter_rrlyr.filter import rrlyr

# number of incoming alerts
nin = dfraw.count()

# number of outgoing alerts corresponding to the filter rrlyr
nout = dfsci.withColumn('isRRLyr', rrlyr('cdsxmatch'))\
  .filter("isRRLyr == true")\
  .count()

outVolume = nout / nin
# 3% in this particular night
```

Note that `nout` could have been computed much faster in this case by using `dfsci.filter('cdsxmatch == RRLyr').count()` (since the column already exists in the alert), but in general when you want to test a new filter you have to apply it as shown above.
