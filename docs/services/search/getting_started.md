The Science Portal is a web application ([https://fink-portal.org](https://fink-portal.org)) to query and visualise Fink processed data. You can run simple queries and quickly display results. After each night, the alert data are aggregated and pushed to HBase tables. This means that you will not only access alert data, but _object_ data, that is all the alerts emitted from day zero for a given object on the sky will be available directly (while in individual alert packet only 30 days of data in the past is available).

point to test suite in the portal


## REST API

The Science Portal uses the Fink REST API under the hood to communicate with the database. You can also use this API to access data programatically. There are several endpoints:

| HTTP Method | URI | Action | Availability |
|-------------|-----|--------|--------------|
| POST/GET | https://fink-portal.org/api/v1/objects| Retrieve single object data from the Fink database | &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/explorer | Query the Fink alert database | &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/latests | Get latest alerts by class | &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/sso | Get confirmed Solar System Object data | &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/ssocand | Get candidate Solar System Object data | &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/tracklet | Get tracklet data | &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/cutouts | Retrieve cutout data from the Fink database| &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/xmatch | Cross-match user-defined catalog with Fink alert data| &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/bayestar | Cross-match LIGO/Virgo sky map with Fink alert data| &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/statistics | Statistics concerning Fink alert data| &#x2611;&#xFE0F; |
| POST/GET | https://fink-portal.org/api/v1/random | Draw random objects from the Fink database| &#x2611;&#xFE0F; |
| GET  | https://fink-portal.org/api/v1/classes  | Display all Fink derived classification | &#x2611;&#xFE0F; |
| GET  | https://fink-portal.org/api/v1/columns  | Display all available alert fields and their type | &#x2611;&#xFE0F; |

You will find more information on how to use the API at [https://fink-portal.org/api](https://fink-portal.org/api), and there are many tutorials at [https://github.com/astrolabsoftware/fink-tutorials](https://github.com/astrolabsoftware/fink-tutorials).

## Limitations

Although the Science Portal and the REST API gives you access to hundreds millions of alerts, it is not designed to run complex queries, or massively download data. Instead you would use the Data Transfer service.

You might notice slowness sometimes, even transient downtimes, especially around 8pm UTC. This is when we perform database operations (heavy writes!). We are working on it!