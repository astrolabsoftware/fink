## Default class search

!!! info "List of arguments"
    The list of arguments for getting latest alerts by class can be found at [https://api.fink-portal.org](https://api.fink-portal.org)

!!! info "What is a class in Fink?"
    The list of Fink class can be found at [https://api.fink-portal.org/api/v1/classes](https://api.fink-portal.org/api/v1/classes). We recommend also to read how the [classification scheme](../..//broker/classification.md) is built.

You can programmatically access the list of all the Fink classes using e.g.:

```bash
curl -H "Content-Type: application/json" -X GET \
    https://api.fink-portal.org/api/v1/classes -o finkclass.json
```

To get the last 5 candidates of the class `Early SN Ia candidate`, you would simply use in a unix shell:

```bash
# Get latests 5 Early SN Ia candidates
curl -H "Content-Type: application/json" -X POST \
    -d '{"class":"Early SN Ia candidate", "n":"5"}' \
    https://api.fink-portal.org/api/v1/latests -o latest_five_sn_candidates.json

# you can also specify parameters in the URL, e.g. with wget:
wget "https://api.fink-portal.org/api/v1/latests?class=Early SN Ia candidate&n=5&output-format=json" \
    -O latest_five_sn_candidates.json
```

In python, you would use

```python
import io
import requests
import pandas as pd

# Get latests 5 Early SN Ia candidates
r = requests.post(
  "https://api.fink-portal.org/api/v1/latests",
  json={
    "class": "Early SN Ia candidate",
    "n": "5"  # (1)!
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

1. This the maximum number of _alerts_ to retrieve. It can lead to several times the same _object_ though.

## Class search restricted in time

You can also specify `startdate` and `stopdate` for your search:

```python
import io
import requests
import pandas as pd

# Get all classified SN Ia from TNS between March 1st 2021 and March 5th 2021
r = requests.post(
  "https://api.fink-portal.org/api/v1/latests",
  json={
    "class": "(TNS) SN Ia",
    "n": "100", # (1)!
    "startdate": "2021-03-01",
    "stopdate": "2021-03-05"
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

1. This the maximum number of _alerts_ to retrieve. There could be less than `n` in the specified period.

## Getting full object data

There are two limitations to this endpoint:

1. Only the `n` last _alerts_ are retrieved: you do not get data for the full corresponding _object_ of each alert.
2. By default all the fields from the class table in Fink are downloaded. .But this table contains only a subset of all [available alert fields](https://api.fink-portal.org/api/v1/schema) that you would have access with a [search by name](objectid.md) for example.

Hence, if you need to query all the _objects_ data for _alerts_ found with a class search, or additional data that is not available in the class table, you would do it in two steps:

```python
# Get the objectId for the last 10 alerts classified SN Ia from TNS
# between March 1st 2021 and March 5th 2021
r0 = requests.post(
  "https://api.fink-portal.org/api/v1/latests",
  json={
    "class": "(TNS) SN Ia",
    "n": "10",
    "startdate": "2021-03-01",
    "stopdate": "2021-03-05",
    "columns": "i:objectId" # (1)!
  }
)

mylist = [val["i:objectId"] for val in r0.json()]
# len(mylist) = 10

# get full lightcurves for all these alerts
r1 = requests.post(
  "https://api.fink-portal.org/api/v1/objects",
  json={
    "objectId": ",".join(mylist),
    "columns": "i:objectId,i:jd,i:magpsf,i:sigmapsf,d:rf_snia_vs_nonia", # (2)!
    "output-format": "json"
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r1.content))
# len(pdf) = 341
```

1. Select only the column you need to get faster results!
2. Select only the column(s) you need to get faster results!

## Alert trends

A new experimental feature has been added to specify a _trend_ to your class search. The available trends at this point are `rising` or `fading`. These two trends are based on the computation of the magnitude rate in the lightcurve (`d:mag_rate`) between two subsequent measurements in the same filter which is one of the feature provided by the [fast transient module](../../broker/science_modules.md).

!!! danger "Meaning of trends"
    The definition of existing trends can change in the future. Actually the current definition of `rising` and `fading` solely based on the sign of `d:mag_rate` between two subsequent measurements in the same filter can be misleading. Maybe we should use a minimum number of points, or combine with other fields. Anyway, this feature is experimental, and the point is to discuss how this can be used efficiently in practice. Please reach us if you think they can be improved, or if you want to propose new trends!

For example, if you want the last Supernovae candidates from the past week which are in a rising state:

```python
import io
import requests
import pandas as pd

from datetime import datetime, timedelta

previous_week = (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")

# Get all
r = requests.post(
  "https://api.fink-portal.org/api/v1/latests",
  json={
    "class": "SN candidate",
    "n": "100",
    "trend": "rising",
    "columns": "i:objectId,i:jd,i:magpsf,d:mag_rate",
    "startdate": previous_week,
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

Note that the trend filtering is done _after_ the class search. So if you request `n=100`, you will get the latest 100 alerts, but then the trend is applied, and you'll probably get fewer alerts than the requested number.

### Specific trends

While the trends `rising` and `fading` apply to all classes, we also provide trends available for a subset of classes. For example, in the case of the `(CTA) Blazar` class, which targets alert with a counterpart in a list of blazars selected by the CTAO collaboration, the trends `low_state` and `new_low_state` are available.

The following snippet will return the blazars selected by CTAO which entered a low state in the last week:

```python
import io
import requests
import pandas as pd

from datetime import datetime, timedelta

previous_week = (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")

# Get all
r = requests.post(
  "https://api.fink-portal.org/api/v1/latests",
  json={
    "class": "(CTA) Blazar",
    "n": "100",
    "trend": "new_low_state",
    "columns": "i:objectId,i:jd,i:magpsf,i:ra,i:dec,d:blazar_stats_m0",
    "startdate": previous_week,
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

These trends have no meaning outside their field of definition, and you should see an error if you are trying to use them for other classes.