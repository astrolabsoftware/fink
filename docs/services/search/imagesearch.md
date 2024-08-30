!!! info "List of arguments"
    The list of arguments for retrieving cutout data can be found at [https://fink-portal.org/api/v1/cutouts](https://fink-portal.org/api/v1/cutouts)

### PNG

In a unix shell, you can retrieve the last cutout of an object by simply using

```bash
curl -H "Content-Type: application/json" \
    -X POST -d \
    '{"objectId":"ZTF21aaxtctv", "kind":"Science"}' \
    https://fink-portal.org/api/v1/cutouts -o cutoutScience.png

# you can also specify parameters in the URL, e.g. with wget:
wget "https://fink-portal.org/api/v1/cutouts?objectId=ZTF21aaxtctv&kind=Science" -O ZTF21aaxtctv_Science.png
```

This will retrieve the `Science` image and save it on `cutoutScience.png`.
In Python, the equivalent script would be:

```python
import io
import requests
from PIL import Image as im

# get data for ZTF21aaxtctv
r = requests.post(
    'https://fink-portal.org/api/v1/cutouts',
    json={
        'objectId': 'ZTF21aaxtctv',
        'kind': 'Science',
    }
)

image = im.open(io.BytesIO(r.content))
image.save('cutoutScience.png')
```

!!! tip "Display in Jupyter Notebook"
    In a notebook, you would use `display(image)` to display the cutout in the page. If it is too small, resize it using `image.resize((height, width))`.

Note you can choose between the `Science`, `Template`, or `Difference` images.
You can also customise the image treatment before downloading, e.g.

```python
import io
import requests
from PIL import Image as im

# get data for ZTF21aaxtctv
r = requests.post(
    'https://fink-portal.org/api/v1/cutouts',
    json={
        'objectId': 'ZTF21aaxtctv',
        'kind': 'Science', # (1)!
        'stretch': 'sigmoid', # (2)!
        'colormap': 'viridis', # (3)!
        'pmin': 0.5, # (4)!
        'pmax': 99.5, # (5)!
        'convolution_kernel': 'gauss' # (6)!
    }
)

image = im.open(io.BytesIO(r.content))
image.save('mysupercutout.png')
```

1. Science, Template, Difference
2. sigmoid[default], linear, sqrt, power, log
3. Valid matplotlib colormap name (see matplotlib.cm). Default is grayscale.
4. The percentile value used to determine the pixel value of minimum cut level. Default is 0.5. No effect for sigmoid.
5. The percentile value used to determine the pixel value of maximum cut level. Default is 99.5. No effect for sigmoid.
6. Convolve the image with a kernel (gauss or box). Default is None (not specified).

By default, you will retrieve the cutout of the last alert emitted for the object `objectId`.
You can also access cutouts of other alerts from this object by specifying their candidate ID:

```python
import io
import requests
import pandas as pd
from PIL import Image as im

# Get all candidate ID with JD for ZTF21aaxtctv
r = requests.post(
    'https://fink-portal.org/api/v1/objects',
    json={
        'objectId': 'ZTF21aaxtctv',
        'columns': 'i:candid,i:jd'
    }
)

pdf_candid = pd.read_json(r.content)

# get image for the first alert
first_alert = pdf_candid['i:candid'].to_numpy()[-1]
r = requests.post(
    'https://fink-portal.org/api/v1/cutouts',
    json={
        'objectId': 'ZTF21aaxtctv',
        'kind': 'Science',
        'candid': first_alert
    }
)

image = im.open(io.BytesIO(r.content))
image.save('mysupercutout_firstalert.png')
```

### FITS

You can also retrieve the original FITS file stored in the alert:

```bash
curl -H "Content-Type: application/json" \
    -X POST -d \
    '{"objectId":"ZTF21aaxtctv", "kind":"Science", "output-format": "FITS"}' \
    https://fink-portal.org/api/v1/cutouts -o cutoutScience.fits
```

or equivalently in Python:

```python
import io
import requests
from astropy.io import fits

# get data for ZTF21aaxtctv
r = requests.post(
    'https://fink-portal.org/api/v1/cutouts',
    json={
        'objectId': 'ZTF21aaxtctv',
        'kind': 'Science',
        'output-format': 'FITS'
    }
)

data = fits.open(io.BytesIO(r.content), ignore_missing_simple=True)
data.writeto('cutoutScience.fits')
```

### 2D array

You can also retrieve only the data block stored in the alert:

```python
import requests

# get data for ZTF21aaxtctv
r = requests.post(
    'https://fink-portal.org/api/v1/cutouts',
    json={
        'objectId': 'ZTF21aaxtctv',
        'kind': 'Science',
        'output-format': 'array'
    }
)

array = r.json()[0]["b:cutoutScience_stampData"]
```