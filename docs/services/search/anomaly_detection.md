!!! info "List of arguments"
    The list of arguments for retrieving anomalous alerts can be found at [https://fink-portal.org/api/v1/resolver](https://fink-portal.org/api/v1/resolver)

This service lets you query the information about anomalous objects in Fink. Each night, Fink selects and stores the top 10 alerts with the most anomalous scores. The Science module was deployed and start producing scores on 2023-01-25.

In python, you would use

```python
import io
import requests
import pandas as pd

r = requests.post(
  "https://fink-portal.org/api/v1/anomaly",
  json={
    "n": int, # (1)!
    "start_date": str, # (2)!
    "stop_date": str, # (3)!
    "columns": str, # (4)!
    "output-format": str
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

1. Optional. Number of objects to retrieve between `stop_date` and `start_date`. Default is 10.
2. Optional. YYYY-MM-DD. Default is 2023-01-25
3. Optional. YYYY-MM-DD. Default is today
4. Optional. Comma-separated column names to retrieve. Default is all columns.

This table has full _alert_ schema, and you can easily gets statistics on the alert classes, example:

```python
import io
import requests
import pandas as pd

# retrieve all anomalies
r = requests.post(
  "https://fink-portal.org/api/v1/anomaly",
  json={
    "n": 10000, # on purpose large
    "stop_date": "2023-05-22",
    "columns": "i:objectId,d:cdsxmatch,i:magpsf"
  }
)
pdf = pd.read_json(io.BytesIO(r.content))

pdf.groupby("d:cdsxmatch")\
    .agg({"i:objectId": "count"})\
    .sort_values("i:objectId", ascending=False) # (1)!
```

1. Output:
```
               i:objectId
d:cdsxmatch
CataclyV*             191
Unknown               170
Mira                   65
RRLyr                  63
LPV*                   52
EB*_Candidate          21
EB*                    20
Star                   14
CV*_Candidate          10
Fail 504               10
Blazar                  6
V*                      6
WD*_Candidate           4
YSO_Candidate           4
PulsV*                  3
Fail 500                3
YSO                     3
Fail 503                2
SN                      2
LP*_Candidate           1
BLLac                   1
QSO                     1
Radio                   1
Seyfert_1               1
TTau*                   1
Em*                     1
ClG                     1
V*?_Candidate           1
BlueStraggler           1
AGN                     1
```

Note the `Fail X` labels are when the [CDS xmatch](http://cdsxmatch.u-strasbg.fr/xmatch) service fails with error code X (web service).

Note that only the `n` last _alerts_ are retrieved: you do not get data for the full corresponding _object_ of each alert. Hence, if you need to query all the _objects_ data for _alerts_ found with a class search, you would do it in two steps:

```python
# retrieve last 10 anomaly objectIds
import io
import requests
import pandas as pd

r = requests.post(
  "https://fink-portal.org/api/v1/anomaly",
  json={
    "n": 10,
    "columns": "i:objectId"
  }
)

# Format output in a DataFrame
oids = [i["i:objectId"] for i in r.json()]

# retrieve full objects data
r = requests.post(
  "https://fink-portal.org/api/v1/objects",
  json={
    "objectId": ",".join(oids),
    "columns": "i:objectId,i:magpsf,i:sigmapsf,d:anomaly_score,d:cdsxmatch,d:lc_features_g,d:lc_features_r",
    "output-format": "json"
  }
)

# Format output in a DataFrame -- 8,011 rows
pdf = pd.read_json(io.BytesIO(r.content))
```

Note the first time, the `/api/v1/objects` query can be long (especially if
you are dealing with variable stars), but then data is cached on the server,
and subsequent queries are much faster. By default, `features` are string arrays. You can easily
cast them into proper arrays using the `json` package:

```python
import json

for col in ["d:lc_features_g", "d:lc_features_r"]:
  pdf[col] =  pdf[col].apply(lambda x: json.loads(x))
```

The anomaly header can be found [here](https://github.com/astrolabsoftware/fink-science/blob/master/fink_science/ad_features/processor.py#L74), and
programmatically accessed via:

```python
from fink_science.ad_features.processor import FEATURES_COLS
print(FEATURES_COLS) # (1)!
```

1. Output:
```
[
  'mean', 'weighted_mean', 'standard_deviation', 'median', 'amplitude', 'beyond_1_std',
  'cusum', 'inter_percentile_range_10', 'kurtosis', 'linear_trend', 'linear_trend_sigma',
  'linear_trend_noise', 'linear_fit_slope', 'linear_fit_slope_sigma', 'linear_fit_reduced_chi2',
  'magnitude_percentage_ratio_40_5', 'magnitude_percentage_ratio_20_10', 'maximum_slope',
  'median_absolute_deviation', 'median_buffer_range_percentage_10', 'percent_amplitude',
  'mean_variance', 'anderson_darling_normal', 'chi2', 'skew', 'stetson_K'
]
```

!!! tip "Search anomaly on the Science Portal"

    On the Science Portal, you can access all alerts selected as anomalous
    using the class search: `class=Anomaly`