# Migration

This page guides you through the API change in Fink.

#### 2024-11-25: Cutout handling

When requesting arrays, you can now ask to download all 3 cutouts at once:

```python
import requests

# get data for ZTF21aaxtctv
r = requests.post(
    'https://fink-portal.org/api/v1/cutouts',
    json={
        'objectId': 'ZTF21aaxtctv',
        'kind': 'All',
        'output-format': 'array'
    }
)

data = r.json()
data.keys()
# dict_keys(['b:cutoutDifference_stampData', 'b:cutoutScience_stampData', 'b:cutoutTemplate_stampData'])
```

This is not available for FITS or PNG formats.

!!! warning "Return type for 2D array"
    We changed the return type from list to dictionary:
    
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

    # before `data` was a list of dictionary -- now it is directly the dictionary
    data = r.json()

    # Before you had to specify the first element [0]
    # array = data[0]["b:cutoutScience_stampData"]

    # Now you access it directly from the key
    array = data["b:cutoutScience_stampData"]
    ```

