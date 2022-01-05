# Fink classification

Based on the filters outputs (which rely on alert content), we infer a classification for each alert (the one you would read on the Science Portal for example). We currently have hundreds of classes that can be found [online](https://fink-portal/api/v1/classes). You can find the implementation of the classification method in [classification.py](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/classification.py), but the rule of thumb is:

1. if an alert has not been flagged by any of the filters, it is tagged as `Unknown`
2. if an alert has a counterpart in the SIMBAD database, its classification is the one from SIMBAD.
3. if an alert has been flagged by one filter, its classification is given by the filter (`Early SN Ia candidate`, `KN candidate`, `SSO candidate`, etc.)
4. if an alert has been flagged by more than one filter (except the SIMBAD one), it is tagged as `Ambiguous`.

Note that this classification is subject to change over time, as we learn new things or when new filters are created. The classification method is versioned (fink-filters version), so that users can track the change. Note that all the filters are not considered for the classification.

### Alert vs object classification

An object on the sky can emit several alerts, and based on available information on each alert, the classification can vary from one alert to another. We do not provide an _object_ classification. This is up to the user to decide on the nature of the object based on the list of alert classifications.
