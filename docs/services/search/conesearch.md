## Simple conesearch

!!! info "List of arguments"
    The list of arguments for running a conesearch can be found at [https://api.fink-portal.org](https://api.fink-portal.org).

This service allows you to search objects in the database matching in position on the sky given by (RA, Dec, radius). The initializer for RA/Dec is very flexible and supports inputs provided in a number of convenient formats. The following ways of initializing a conesearch are all equivalent:

* 193.822, 2.89732, 5
* 193d49m18.267s, 2d53m50.35s, 5
* 12h55m17.218s, +02d53m50.35s, 5
* 12 55 17.218, +02 53 50.35, 5
* 12:55:17.218, 02:53:50.35, 5

!!! warning "Search radius"
    The search radius is always in arcsecond.

In a unix shell, you would simply use

```bash
# Get all objects falling within (center, radius) = ((ra, dec), radius)
curl -H "Content-Type: application/json" -X POST \
    -d '{"ra":"193.822", "dec":"2.89732", "radius":"5"}' \
    https://api.fink-portal.org/api/v1/conesearch -o conesearch.json

# you can also specify parameters in the URL, e.g. with wget:
wget "https://api.fink-portal.org/api/v1/conesearch?ra=193.822&dec=2.89732&radius=5&startdate=2021-06-10 05:59:37.000&window=7&output-format=json" -O conesearch.json
```

In python, you would use

```python
import io
import requests
import pandas as pd

# Get all objects falling within (center, radius) = ((ra, dec), radius)
r = requests.post(
  "https://api.fink-portal.org/api/v1/conesearch",
  json={
    "ra": "193.822",
    "dec": "2.89732",
    "radius": "5"
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

!!! warning "Maximum radius length"
    The maximum radius length is 18,000 arcseconds (5 degrees).


Note that in case of several objects matching, the results will be sorted according to the column
`v:separation_degree`, which is the angular separation in degree between the input (ra, dec) and the objects found. In addition, you can specify time boundaries:

```python
import io
import requests
import pandas as pd

# Get all objects falling within (center, radius) = ((ra, dec), radius)
# between 2021-06-25 05:59:37.000 (included) and 2021-07-01 05:59:37.000 (excluded)
r = requests.post(
  "https://api.fink-portal.org/api/v1/conesearch",
  json={
    "ra": "193.822",
    "dec": "2.89732",
    "radius": "5",
    "startdate": "2021-06-10 05:59:37.000",
    "window": 7 # in days
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

!!! warning "Time boundaries and first detection"
    When specifying time boundaries, you will restrict the search to alerts whose first detection was within the specified range of dates (and not all transients seen during this period).

Here is the performance of the service for querying a
single object (database of 1.3TB, about 40 million alerts):

![conesearch](https://user-images.githubusercontent.com/20426972/123047697-e493a500-d3fd-11eb-9f30-216dce9cbf43.png)

_circle marks with dashed lines are results for a full scan search (~2 years of data, 40 million alerts), while the upper triangles with dotted lines are results when restraining to 7 days search. The numbers close to markers show the number of objects returned by the conesearch._

There are two limitations to this endpoint:

1. If several alerts from the same object match the query, we group information and only display the data from the last alert.
2. By default all the fields from the conesearch table in Fink are downloaded. But this table contains only a subset of all [available alert fields](https://api.fink-portal.org/api/v1/schema) that you would have access with a [search by name](objectid.md) for example.

Hence, if you need to query all the _objects_ data for _alerts_ found with a conesearch, or additional data that is not available in the class table, you would do it in two steps:

```python
# Get the objectId for the alert(s) within a circle on the sky
r0 = requests.post(
  "https://api.fink-portal.org/api/v1/conesearch",
  json={
    "ra": "193.822",
    "dec": "2.89732",
    "radius": "5",
    "columns": "i:objectId" # (1)!
  }
)

mylist = [val["i:objectId"] for val in r0.json()]
# len(mylist) = 1

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
# len(pdf) = 14
```

1. Select only the column you need to get faster results!
2. Select only the column(s) you need to get faster results!

## Crossmatch with catalogs

!!! danger "/api/v1/xmatch endpoint does not exist anymore"
    The endpoint `/api/v1/xmatch` was a wrapper around `/api/v1/conesearch` and did not provide any additional performance benefits. To reduce maintenance costs, it has been deprecated. It may be reintroduced if significant performance improvements are achieved.
