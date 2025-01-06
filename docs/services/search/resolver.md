!!! info "List of arguments"
    The list of arguments for resolving names can be found at [https://api.fink-portal.org](https://api.fink-portal.org)

Naming objects is a complex endeavor, often resulting in multiple names or designations for the same object. In the era of big data, this challenge becomes even more pronounced, as the need to quickly assign names to millions of objects can lead to non-intuitive designation processes.

Instead of proposing a new naming scheme, we aim to provide a service that allows users to explore existing names for a given object. Currently, you can resolve ZTF object names within the SIMBAD database, the Transient Name Server, and Solar System databases recognized by the Quaero service from SSODNET. Additionally, this service allows you to determine if a corresponding ZTF object exists for any object found in these three databases.

We are committed to expanding this service and will continue to add new sources of information.

### TNS to ZTF

I have a TNS identifier, are there ZTF objects corresponding?

```python
import io
import requests
import pandas as pd

r = requests.post(
  'https://api.fink-portal.org/api/v1/resolver',
  json={
    'resolver': 'tns',
    'name': 'SN 2023vwy'
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content)) # (1)!
```

1. Output:
```
d:declination  d:fullname d:internalname       d:ra  d:redshift d:type       key:time
0      52.219894  SN 2023vwy     ATLAS23url  47.765951       0.031  SN Ia  1704445385951
1      52.219894  SN 2023vwy   ZTF23abmwsrw  47.765951       0.031  SN Ia  1704445385951
```

!!! tip "Downloading the full TNS table"
    You can also download the full TNS table by specifying an empty name:

    ```python
    import io
    import requests
    import pandas as pd

    r = requests.post(
    'https://api.fink-portal.org/api/v1/resolver',
    json={
        'resolver': 'tns',
        'name': '',
        'nmax': 1000000
    }
    )

    pdf = pd.read_json(io.BytesIO(r.content)) # (1)!
    ```

    1. Output:
    ```
            d:declination  d:fullname     d:internalname           d:ra d:redshift  d:type       key:time
    0           -55.409677    AT 1976S  GSC2.3 SATX032616     286.245594        NaN     nan  1704445383818
    1           -25.480611    AT 1978M  GSC2.3 S64P036598     122.320327        NaN     nan  1704445383818
    2            47.530987   AT 1991bm  GSC2.3 N0ZY037003     273.810015        NaN     nan  1704445388697
    3            14.414089   AT 1992bw  GSC2.3 NB6I007107       1.510637        NaN     nan  1704445388697
    4            25.566352   AT 1993an  GSC2.3 NBIP012777      10.505964        NaN     nan  1704445383818
    ...                ...         ...                ...            ...        ...     ...            ...
    174736      40.9886174  SN 2023zzk         ATLAS23xnr     54.7199172   0.020127   SN II  1704445385595
    174737      40.9886174  SN 2023zzk       ZTF23abtycgb     54.7199172   0.020127   SN II  1704445385595
    174738  -42.6586722222  SN 2023zzn         ATLAS23xjb  46.8617011111      0.094  SLSN-I  1704445385595
    174739  -24.7868458611   SN 2024fa         ATLAS24adw   36.255712664       0.01   SN II  1704445385595
    174740  -24.7868458611   SN 2024fa             PS24ca   36.255712664       0.01   SN II  1704445385595

    [174741 rows x 7 columns]
    ```

### ZTF to TNS

I have a ZTF object name, are there counterparts in TNS?


```python
import io
import requests
import pandas as pd

r = requests.post(
  'https://api.fink-portal.org/api/v1/resolver',
  json={
    'resolver': 'tns',
    'reverse': True,
    'name': 'ZTF23abmwsrw'
  }
)

# Format output in a DataFrame
pdf = pd.read_json(io.BytesIO(r.content)) # (1)!
```

1. Output:
```
   d:declination  d:fullname d:internalname       d:ra d:type       key:time
0      52.219904  AT 2023vwy   ZTF23abmwsrw  47.765935    nan  1698788550829
1      52.219894  SN 2023vwy   ZTF23abmwsrw  47.765951  SN Ia  1702926332847
```

### SIMBAD to ZTF

I have an astronomical object name referenced in SIMBAD, are there counterparts in ZTF? As these objects can be extended, we typically provide coordinates, and then you need to run a conesearch:


```python
import io
import requests
import pandas as pd

r = requests.post(
  'https://api.fink-portal.org/api/v1/resolver',
  json={
    'resolver': 'simbad',
    'name': 'Markarian 2'
  }
)

if r.json() != []:
    print('Object found!')
    print(r.json())
    print()

    r = requests.post(
      'https://api.fink-portal.org/api/v1/explorer',
      json={
        'ra': r.json()[0]['jradeg'],
        'dec': r.json()[0]['jdedeg'],
        'radius': 60
      }
    )

    # Format output in a DataFrame
    pdf = pd.read_json(io.BytesIO(r.content))
    print('Object(s) in ZTF: {}'.format(pdf['i:objectId'].to_numpy()))
else:
    print('No objects found')
```

Leading in this example to:

```
Object found!
[
  {
    'name': 'Si=Simbad, all IDs (via url)',
    'oid': 1579005,
    'oname': 'Mrk 2',
    'otype': 'GiG',
    'jpos': '01:54:53.80 +36:55:04.6',
    'jradeg': 28.7241958,
    'jdedeg': 36.9179556,
    'refPos': '2006AJ....131.1163S',
    'z': None,
    'MType': 'SBa',
    'nrefs': 138
  }
]

Object(s) in ZTF: ['ZTF18aabfjoi']
```

### ZTF to SIMBAD

I have a ZTF object name, are there counterparts in SIMBAD?


```python
import io
import requests
import pandas as pd

r = requests.post(
  'https://api.fink-portal.org/api/v1/resolver',
  json={
    'resolver': 'simbad',
    'reverse': True,
    'name': 'ZTF18aabfjoi'
  }
)
pdf = pd.read_json(io.BytesIO(r.content)) # (1)!
```

1. Output:
```
  d:cdsxmatch             i:candid      i:dec          i:jd    i:objectId       i:ra
0    GinGroup  1045306711115010048  36.917909  2.458800e+06  ZTF18aabfjoi  28.724092
1    GinGroup  1400219061115010048  36.917912  2.459155e+06  ZTF18aabfjoi  28.724130
2    GinGroup  1626461821115010048  36.917924  2.459381e+06  ZTF18aabfjoi  28.724110
3    GinGroup  1977476361115010048  36.917913  2.459732e+06  ZTF18aabfjoi  28.724100
4    GinGroup  2119325081115010048  36.917892  2.459874e+06  ZTF18aabfjoi  28.724094
```

5 different alerts from the same object (`ZTF18aabfjoi`).

### SSO to ZTF

I have a SSO name or number, are there ZTF objects corresponding?
You first need to resolve the corresponding ZTF `ssnamenr`:

```python
import io
import requests
import pandas as pd

r = requests.post(
  'https://api.fink-portal.org/api/v1/resolver',
  json={
    'resolver': 'ssodnet',
    'name': '624188'
  }
)

pdf = pd.read_json(io.BytesIO(r.content)) # (1)!
```

1. Output:
```
     i:name  i:number i:ssnamenr
0  2002 MA6    624188    2002MA6
1  2002 MA6    624188     624188
2  2002 MA6    624188   2002MA06
3  2002 MA6    624188     624188
```

and then search for corresponding alerts for all `ssnamenr`:

```python
import io
import requests
import pandas as pd

r = requests.post(
  'https://api.fink-portal.org/api/v1/sso',
  json={
    'n_or_d': ','.join(pdf['i:ssnamenr'].to_numpy()),
    'columns': 'i:objectId,i:ra,i:dec,i:magpsf,i:sigmapsf,i:ssnamenr'
  }
)
sso = pd.read_json(io.BytesIO(r.content)) # (1)!
```

1. Output:
```
        i:dec   i:magpsf    i:objectId       i:ra  i:sigmapsf i:ssnamenr
0   38.761579  19.651100  ZTF19acrplsa  84.760898    0.201959   2002MA06
1   35.097359  19.678823  ZTF19adagirr  74.131671    0.154512   2002MA06
2   32.709072  20.320038  ZTF23aazubcu  38.761726    0.181345    2002MA6
3   36.039245  20.226397  ZTF23abcakzn  42.951283    0.208451    2002MA6
4   37.399041  20.620817  ZTF23abecthp  44.314170    0.181139    2002MA6
5   37.412476  19.931238  ZTF23abeeoen  44.324915    0.122155    2002MA6
6   38.092562  19.839323  ZTF23abfvtyr  44.875277    0.110749    2002MA6
7   38.102591  20.627150  ZTF23abfxptv  44.881451    0.182423    2002MA6
8   39.028132  19.811459  ZTF23abhahgo  45.412434    0.116035    2002MA6
9   40.087669  19.518000  ZTF23abidfxt  45.472807    0.134570     624188
10  40.253863  20.037786  ZTF23abilvaz  45.374426    0.172761     624188
11  40.263377  19.517801  ZTF23abiotst  45.365776    0.116226     624188
12  40.717564  19.452196  ZTF23abkempy  44.508594    0.087599     624188
13  40.718352  19.871597  ZTF23abkfquu  44.504111    0.144978     624188
14  40.760788  19.485823  ZTF23abkwjee  44.211183    0.093203     624188
15  40.777337  19.365993  ZTF23ablsjlg  43.858879    0.078582     624188
16  40.777324  19.830032  ZTF23ablthyz  43.850151    0.109873     624188
17  40.046433  19.359879  ZTF23abogmeh  40.809196    0.127990     624188
18  39.832539  19.788800  ZTF23aboqpks  40.349063    0.139298     624188
19  39.153497  19.270357  ZTF23abpqqiz  39.155381    0.140963     624188
20  39.134613  19.803095  ZTF23abpsedk  39.124796    0.165054     624188
21  38.846470  19.866776  ZTF23abqbtrv  38.709943    0.139531     624188
22  38.826889  19.179682  ZTF23abqdzil  38.680996    0.095241     624188
23  38.508815  19.166033  ZTF23abqphse  38.268334    0.072787     624188
24  33.059517  19.892330  ZTF23absmjqg  35.439591    0.186579     624188
25  32.477462  19.840815  ZTF23abtpaxv  35.544006    0.173815     624188
26  32.294998  19.863436  ZTF23abtxgba  35.595829    0.105220     624188
27  32.292988  19.976093  ZTF23abtxjux  35.596339    0.081324     624188
28  32.094647  20.584602  ZTF23abuivpe  35.662240    0.160992     624188
29  31.925860  20.086443  ZTF23abuppio  35.728953    0.138072     624188
30  31.916201  20.444067  ZTF23abuqdev  35.732460    0.172873     624188
```

!!! tip "Exact/inexact searches"

    By default, the SSO resolver will perform an _inexact_ search, meaning it will return the exact search plus closest matches. The number of closest matches is controlled by the parameter `nmax`, with default `nmax=10`:

    ```python
    import io
    import requests
    import pandas as pd

    r = requests.post(
    'https://api.fink-portal.org/api/v1/resolver',
    json={
        'resolver': 'ssodnet',
        'name': '33'
    }
    )

    pdf = pd.read_json(io.BytesIO(r.content)) # (1)!
    ```

    1. Output:
    ```
            i:name  i:number  i:ssnamenr
    0     Polyhymnia        33          33
    1     Polyhymnia        33          33
    2      Adalberta       330         330
    3      Adalberta       330         330
    4       3300 T-1     17325       17325
    5       3300 T-2     69209       69209
    6       3300 T-3     79071       79071
    7      McGlasson      3300        3300
    8      McGlasson      3300        3300
    9  Chenjiansheng     33000       33000
    ```

    Note that there are duplicates, as data is indexed by `name`, `number`, and `ssnamenr`.
    If you want to perform an _exact_ search, just put `nmax=1`:

    ```python
    import io
    import requests
    import pandas as pd

    r = requests.post(
    'https://api.fink-portal.org/api/v1/resolver',
    json={
        'resolver': 'ssodnet',
        'name': '33',
        'nmax': 1
    }
    )

    pdf = pd.read_json(io.BytesIO(r.content)) # (1)!
    ```

    1. Output:
    ```
        i:name  i:number  i:ssnamenr
    0  Polyhymnia        33          33
    1  Polyhymnia        33          33
    ```

### ZTF to SSO

I have a ZTF object name, is there a counterpart in the SsODNet quaero database, and what are all the known aliases to Fink?

```python
import io
import requests
import pandas as pd

r = requests.post(
  'https://api.fink-portal.org/api/v1/resolver',
  json={
    'resolver': 'ssodnet',
    'reverse': True,
    'name': 'ZTF23abidfxt'
  }
)

if r.json() != []:
    name = r.json()[0]['i:ssnamenr']
    print('Asteroid counterpart found with designation {}'.format(name))
    print()

    r2 = requests.post(
      'https://api.fink-portal.org/api/v1/resolver',
      json={
        'resolver': 'ssodnet',
        'name': name,
        'nmax': 1
      }
    )

    pdf = pd.read_json(io.BytesIO(r2.content))
    print('In the Fink database, {} also corresponds to: '.format(name))
    print(pdf)
```

Leading to:

```
Asteroid counterpart found with designation 624188

In the Fink database, 624188 also corresponds to:
  i:source i:ssnamenr
0    number   2002MA06
1    number    2002MA6
2    number     624188
3  ssnamenr     624188
```
