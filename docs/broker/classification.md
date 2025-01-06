# Alert classification

## Sources of information

Following the analysis of alerts, we can identify three primary sources of information:

1. The original alert parameters received from surveys (ZTF/LSST), such as magnitude, position, emission time, and so on.
2. Supplementary data obtained from cross-referencing in Fink with external databases or catalogs, including SIMBAD, TNS, Gaia, VSX, 4LAC, PanSTARRS, and others.
3. Additional information derived from user-defined processing in Fink, which may include statistical features, tags, machine learning scores, and more.

The challenge now lies in integrating these fields to derive meaningful scientific insights. There is no definitive ground truth in this context, and the possibilities for combinations are limitless, varying based on the specific target.

!!! tip "Alert vs object classification"

	An astronomical object on the sky can emit several alerts as its flux evolves, and based on available information on each alert, the classification can vary from one alert to another. We do not provide an _object_ classification, but rather classification for each alert. You will for example find the evolution of the classification in the Science Portal (e.g. [ZTF23aabqqoi](https://fink-portal.org/ZTF23aabqqoi)) just above the lightcurve:

	![Screenshot](../img/fink-classification.png)

	This is up to the user to decide on the nature of the object based on the list of alert classifications.

## Designing a specific classification

To facilitate the identification of noteworthy events, users can create filters that combine multiple alert fields, allowing them to generate meaningful tags tailored to their research needs. For instance, one of the [filters](filters.md) designed for [Kilonova candidates](https://github.com/astrolabsoftware/fink-filters/blob/be30474e10d041afe8da992ac1fe37da71db230f/fink_filters/filter_kn_candidates/filter.py#L84-L94), utilized within the [GRANDMA network](https://grandma.ijclab.in2p3.fr/), is based on the following outputs:

- The results from a [Kilonova classifier](https://github.com/astrolabsoftware/fink-science/tree/master/fink_science/kilonova)
- Tags obtained from cross-referencing with the SIMBAD database
- Tags derived from cross-referencing with the Minor Planet Center database
- Fundamental parameters such as emission time, real-bogus score, and star-galaxy score.

This particular combination serves to identify [kilonova-like events](https://fink-portal.org/?action=class&class=Kilonova%20candidate), but alternative approaches could also be employed to achieve similar results.

## Provided classification scheme by the Fink team

Although creating filters aimed at specific events is ideal for targeted scientific inquiries and real-time requirements, we also aim to establish a comprehensive classification scheme. This scheme would facilitate preliminary searches in the Fink database, help users develop intuition, and allow for exploration of the sky without preconceived notions.

In this respect, we established a basic alert classification scheme, based on the various sources of information listed above. Hundreds of classes have been infered, and they can be browsed at [https://api.fink-portal.org/api/v1/classes](https://api.fink-portal.org/api/v1/classes). They belong to 3 broad categories:

1. Tags obtained from spatially cross-referencing with the SIMBAD database (e.g. `EB*`, `Blazar`, `gammaBurst`, `LensedQ`, etc.)
2. Tags obtained from spatially cross-referencing with the TNS database (e.g. `SN Ia`, `TDE`, etc.)
3. Tags obtained from using Fink science module results (e.g. `Early SN Ia candidate`, `Kilonova candidate`, `Solar System MPC`, ...)

While the first two categories depend on established sources of information (with blending as an exception), the last category, which utilizes Fink science modules, typically returns candidate events that are associated with a probability. You can find the implementation of the classification method in [classification.py](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/classification.py), but the rule of thumb is:

1. if an alert has no additional information from Fink (cross-reference, machine learning score, etc.), it is tagged as `Unknown`
2. if an alert has a counterpart in the TNS database, its classification is the one from TNS.
3. if an alert has a counterpart in the SIMBAD database, its classification is the one from SIMBAD.
4. if an alert has been flagged by one user-defined filter, its classification is given by the filter (`Early SN Ia candidate`, `KN candidate`, `SSO candidate`, etc.)
5. if an alert has been flagged by more than one user-defined filter, it is tagged as `Ambiguous`.

Note that the definition of this classification is subject to change over time, as we learn new things or when new filters are created. The classification method is versioned (see [fink-filters release](https://github.com/astrolabsoftware/fink-filters/releases)), so that users can track the changes. Note that not all the filters are considered for the classification.

## Tags from TNS

In our database, we index data according to their tag in TNS, but this is not (yet) used to compute the classification in Fink. In other words you can search for data with a specific label in TNS (either from the Science Portal or from the API), but the TNS tag will not appear in the resulting classification (`v:classification`). We intend to add the TNS labels inside the Fink classification in the future.

In the meantime, if you want to know if an object has been labeled in TNS from your search (other than searching for a TNS specific tag), you can use the [TNS resolver](../services/search/resolver.md):

```python
import requests

# Get latests 100 Early SN Ia candidates ID from Fink
r = requests.post(
    "https://api.fink-portal.org/api/v1/latests",
    json={
        "class": "Early SN Ia candidate",
        "columns": "i:objectId",
        "n": "100"
    }
)

# Get the Fink resolver to search for 
# counterparts in TNS for each ZTF ID:
for obj in r.json():
    r0 = requests.post(
        "https://api.fink-portal.org/api/v1/resolver",
        json={
            "resolver": "tns",
            "reverse": True,
            "name": obj["i:objectId"]
        }
    )
    if r0.json() != []:
        print(obj["i:objectId"], r0.json())
```
