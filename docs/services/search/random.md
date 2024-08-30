!!! info "List of arguments"
    The list of arguments for drawing random objects can be found at [https://fink-portal.org/api/v1/random](https://fink-portal.org/api/v1/random)

This service lets you draw random objects (full lightcurve) from the Fink database (200+ million alerts). This is still largely experimental.

In a unix shell, you would simply use

```bash
# Get the data for 8 *objects* randomly drawn from the +120 million alerts in Fink
curl -H "Content-Type: application/json" -X POST \
    -d '{"n":8, "output-format":"csv"}' \
    https://fink-portal.org/api/v1/random -o random.csv

# you can also specify parameters in the URL, e.g. with wget:
wget "https://fink-portal.org/api/v1/random?n=8&output-format=json" -O random.json
```

In python, you would use

```python
import io
import requests
import pandas as pd

r = requests.post(
  'https://fink-portal.org/api/v1/random',
  json={
    'n': integer, # (1)!
    'class': classname, # (2)!
    'seed': integer, # (3)!
    'columns': str, # (4)!
    'output-format': output_format, # (5)!
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content))
```

1. Number of random objects to get. Maximum is 16.
2. Optional, specify a Fink class.
3. Optional, the seed for reproducibility
4. Optional, comma-separated column names
5. Optional [json[default], csv, parquet, votable]

!!! warning "Maximum number of objects"
    As this service is experimental, the number of random objects returned for a single call cannot be greater than 16.

Concerning the classname, see h[ttps://fink-portal.org/api/v1/classes](ttps://fink-portal.org/api/v1/classes). If you do not specify the parameter `class`, you will get random objects from all classes. For better performances, we advice to choose a classname, and limit colunms to transfer, e.g.:

```python
import io
import requests
import pandas as pd

# 16 random Early SN Ia candidates
r = requests.post(
  'https://fink-portal.org/api/v1/random',
  json={
    'n': 16, # Number of random objects to get
    'class': 'Early SN Ia candidate', # Optional, specify a Fink class.
    'seed': 0, # Optional, the seed for reproducibility
    'columns': 'i:objectId,i:jd,i:magpsf,i:fid', # Optional, comma-separated column names
  }
)
```

Note that this returns data for *objects* (and not just alerts).

!!! warning "Reproducibility"
    The `seed` is used to fix the date boundaries, hence it is valid only over a small period of time as the database is updated everyday, and more dates are added... So consider your seed valid over 24h (this might change in the future).
