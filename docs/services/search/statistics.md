!!! info "List of arguments"
    The list of arguments for accessing statistics can be found at [https://api.fink-portal.org](https://api.fink-portal.org).

The [statistics](https://fink-portal.org/stats) page makes use of the REST API.
If you want to further explore Fink statistics, get numbers for a talk, or create your own dashboard based on Fink data, you can do all of these yourself using the REST API. Here is an example using Python:

```python
import io
import requests
import pandas as pd

# get stats for all the year 2021
r = requests.post(
  "https://api.fink-portal.org/api/v1/statistics",
  json={
    "date": "2021",
    "output-format": "json"
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

Each row is an observinng night. Note `date` can be either a given night (`YYYYMMDD`), month (`YYYYMM`), year (`YYYY`), or all observing night (empty string). The schema of the dataframe is the following:

| Key                        | Description                                                        |
|---------------------------|--------------------------------------------------------------------|
| key:key                   | Observation date in the form ztf_YYYYMMDD                         |
| basic:raw                 | Number of alerts received                                           |
| basic:sci                 | Number of alerts processed (passing quality cuts)                 |
| basic:n_g                 | Number of measurements in the g band                               |
| basic:n_r                 | Number of measurements in the r band                               |
| basic:exposures           | Number of exposures (30 seconds)                                   |
| basic:fields              | Number of fields visited                                           |
| class:simbad_tot          | Number of alerts with a counterpart in SIMBAD                     |
| class:simbad_gal          | Number of alerts with a close-by candidate host-galaxy in SIMBAD  |
| class:Solar System MPC     | Number of alerts with a counterpart in MPC (SSO)                  |
| class:SN candidate        | Number of alerts classified as SN by Fink                          |
| class:Early SN Ia candidate| Number of alerts classified as early SN Ia by Fink                 |
| class:Kilonova candidate  | Number of alerts classified as Kilonova by Fink                    |
| class:Microlensing candidate| Number of alerts classified as Microlensing by Fink               |
| class:Solar System candidate| Number of alerts classified as SSO candidates by Fink             |
| class:Tracklet            | Number of alerts classified as satellite glints or space debris by Fink |
| class:Unknown             | Number of alerts without classification                             |

All other fields starting with `class:` are crossmatch from the SIMBAD database.
