# Migration

This page guides you through the API change in Fink.

---

#### 2025-01-06: /api/v1/columns becomes /api/v1/schema

The endpoint `/api/v1/columns` has been renamed `/api/v1/schema` with the new API URL (see below). This means `https://fink-portal.org/api/v1/columns` becomes `https://api.fink-portal.org/api/v1/schema`.

We encourage all users to update the URL as soon as possible and report any problems.

---

#### 2025-01-06: Deprecated endpoints

As part of the API migration (see below), we deprecated two endpoints:

- `/api/v1/xmatch`
- `/api/v1/random`
- `/api/v1/explorer`

The endpoint `/api/v1/xmatch` was a wrapper around `/api/v1/conesearch` and did not provide any additional performance benefits. To reduce maintenance costs, it has been deprecated. It may be reintroduced if significant performance improvements are achieved.

The endpoint `/api/v1/random` was never used as far as we know. If you were a user of it, please let us know, and it will be re-introduced.

The endpoint `/api/v1/explorer` has been replaced by `/api/v1/conesearch`.

Note that these endpoints are still accessible from the old API URL until January 30, 2025.

---

#### 2025-01-06: Migration to new API URL

As part of the transition to a new system for Rubin, the URL to access the API will change from `https://fink-portal.org/api/v1/<endpoint>` to `https://api.fink-portal.org/api/v1/<endpoint>`. Both URLs will be valid until January 30, 2025, at which point only `https://api.fink-portal.org/api/v1/<endpoint>` will be valid. We encourage all users to update the URL as soon as possible and report any problems.

Note that the underlying code has been improved for better performance, and in addition to this documentation website, users can access the API documentation at [https://api.fink-portal.org](https://api.fink-portal.org) where all endpoints are detailed.

---

#### 2024-11-25: Cutout handling

When requesting arrays, you can now ask to download all 3 cutouts at once:

```python
import requests

# get data for ZTF21aaxtctv
r = requests.post(
    'https://api.fink-portal.org/api/v1/cutouts',
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
        'https://api.fink-portal.org/api/v1/cutouts',
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

