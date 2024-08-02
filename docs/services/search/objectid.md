## Retrieve object data

!!! info "List of arguments"
    The list of arguments for retrieving object data can be found at [https://fink-portal.org/api/v1/objects](https://fink-portal.org/api/v1/objects)

Alerts emitted by the same astronomical object share the same `objectId` identifier. This identifier typically starts with `ZTF` followed by the year of the first discovery, and a sequence of letters. The main table in Fink database is indexed against this identifier, and you can efficiently query all alerts from the same `objectId`. In a unix shell, you would simply use

```bash
# Get data for ZTF21aaxtctv and save it in a CSV file
curl -H "Content-Type: application/json" -X POST \
    -d '{"objectId":"ZTF21aaxtctv", "output-format":"csv"}' \
    https://fink-portal.org/api/v1/objects -o ZTF21aaxtctv.csv

# you can also specify parameters in the URL, e.g. with wget:
wget "https://fink-portal.org/api/v1/objects?objectId=ZTF21aaxtctv&output-format=json" -O ZTF21aaxtctv.json
```

In python, you would use

```python
import io
import requests
import pandas as pd

# get data for ZTF21aaxtctv
r = requests.post(
  "https://fink-portal.org/api/v1/objects",
  json={
    "objectId": "ZTF21aaxtctv",
    "output-format": "json"
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

You can retrieve the data for several objects at once:

```python
mylist = ["ZTF21aaxtctv", "ZTF21abfmbix", "ZTF21abfaohe"]

# get data for many objects
r = requests.post(
  "https://fink-portal.org/api/v1/objects",
  json={
    "objectId": ",".join(mylist),
    "output-format": "json"
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

!!! warning "Do not abuse!"
    Although the REST API gives you access to hundreds of millions of alerts, it is not designed to massively download data. If you have hundreds of objects to query, you probably want to select only a subset of columns (see below), or you can use the [Data Transfer service](services/data_transfer).

You can also get a votable:

```python
import io
import requests
from astropy.io import votable

# get data for ZTF21aaxtctv
r = requests.post(
  "https://fink-portal.org/api/v1/objects",
  json={
    "objectId": "ZTF21aaxtctv",
    "output-format": "votable"
  }
)

vt = votable.parse(io.BytesIO(r.content))
```

!!! tip "Optimisation: selecting a subset of columns"
    By default, we transfer all available data fields (original ZTF fields and Fink science module outputs). But you can also choose to transfer only a subset of the fields (see [https://fink-portal.org/api/v1/columns](https://fink-portal.org/api/v1/columns) for the list of available fields):

    ```python
    # select only jd, magpsf and sigmapsf
    r = requests.post(
        "https://fink-portal.org/api/v1/objects",
        json={
            "objectId": "ZTF21aaxtctv",
            "columns": "i:jd,i:magpsf,i:sigmapsf" # (1)!
        }
    )
    ```

    1. Note that the fields should be comma-separated. Unknown field names are ignored. You cannot select fields starting with `v:` because they are created on-the-fly on the server at runtime and not stored in the database.

    This way, the transfer will be much faster than querying everything!

## Upper limits and bad quality data

You can also retrieve upper limits and bad quality data (as defined by Fink quality cuts)
alongside valid measurements. For this you would use the argument `withupperlim`.

!!! tip "Checking data quality"
    Note that the returned data will contained a new column, `d:tag`, to easily check data type:
    `valid` (valid alert measurements), `upperlim` (upper limits), `badquality` (alert measurements that did not pass quality cuts).

```python
import io
import requests
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_context("talk")

# get data for ZTF21aaxtctv
r = requests.post(
    "https://fink-portal.org/api/v1/objects",
    json={"objectId": "ZTF21aaxtctv", "withupperlim": "True"},
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))

fig = plt.figure(figsize=(15, 6))

colordic = {1: "C0", 2: "C1"}
namedic = {1: "g", 2: "r"}

for filt in pdf["i:fid"].unique():
    mask_filt = pdf["i:fid"] == filt

    # The column `d:tag` is used to check data type
    mask_valid = pdf["d:tag"] == "valid"
    plt.errorbar(
        pdf[mask_valid & mask_filt]["i:jd"].apply(lambda x: x - 2400000.5),
        pdf[mask_valid & mask_filt]["i:magpsf"],
        pdf[mask_valid & mask_filt]["i:sigmapsf"],
        ls="",
        marker="o",
        color=colordic[filt],
        label="{} band".format(namedic[filt]),
    )

    mask_upper = pdf["d:tag"] == "upperlim"
    plt.plot(
        pdf[mask_upper & mask_filt]["i:jd"].apply(lambda x: x - 2400000.5),
        pdf[mask_upper & mask_filt]["i:diffmaglim"],
        ls="",
        marker="^",
        color=colordic[filt],
        markerfacecolor="none",
        label="{} band (upper limit)".format(namedic[filt]),
    )

    maskBadquality = pdf["d:tag"] == "badquality"
    plt.errorbar(
        pdf[maskBadquality & mask_filt]["i:jd"].apply(lambda x: x - 2400000.5),
        pdf[maskBadquality & mask_filt]["i:magpsf"],
        pdf[maskBadquality & mask_filt]["i:sigmapsf"],
        ls="",
        marker="v",
        color=colordic[filt],
        label="{} band (bad quality)".format(namedic[filt]),
    )

plt.gca().invert_yaxis()
plt.xlabel("Modified Julian Date")
plt.ylabel("Magnitude")
plt.legend()
plt.show()
```

![sn_example](https://user-images.githubusercontent.com/20426972/113519225-2ba29480-958b-11eb-9452-15e84f0e5efc.png)

## Cutouts

Finally, you can also request data from cutouts stored in alerts (science, template and difference).
Simply set `withcutouts` to `True` in the json payload:

```python
import requests
import pandas as pd
import matplotlib.pyplot as plt

# transfer cutout data
r = requests.post(
  "https://fink-portal.org/api/v1/objects",
  json={
    "objectId": "ZTF21aaxtctv",
    "withcutouts": True # (1)!
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))

columns = [
    "b:cutoutScience_stampData",
    "b:cutoutTemplate_stampData",
    "b:cutoutDifference_stampData"
]

for col in columns:
    # 2D array
    data = pdf[col].to_numpy()[0]

    # do whatever plotting

plt.show()
```

1. By default this will download the 3 cutouts. You can also specify only one cutout by adding the argument `cutout-kind`:
```python
# transfer only science cutout data
r = requests.post(
  "https://fink-portal.org/api/v1/objects",
  json={
    "objectId": "ZTF21aaxtctv",
    "withcutouts": True,
    "cutout-kind": "Science"
  }
)
```

See [here](https://github.com/astrolabsoftware/fink-science-portal/blob/1dea22170449f120d92f404ac20bbb856e1e77fc/apps/plotting.py#L584-L593) how we do in the Science Portal to display cutouts. Note that you need to flip the array to get the correct orientation on sky (`data[::-1]`).
