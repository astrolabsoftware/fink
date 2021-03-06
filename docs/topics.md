# Fink topics

Each night, telescopes are sending raw alerts and the broker enriches these alerts by adding new information to identify interesting candidates for follow-up observations or further scientific processing. The raw incoming stream volume is huge, and each user might want to focus only on a subset of the stream. Hence the output of the broker contains filters that flag only particular parts of the stream to be distributed. Criteria are based on the [alert entries](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html): position, flux, properties, ... and [Fink added values](science/added_values.md).

Each stream subset from a particular filter is identified by a topic (ID). This stream can be accessed outside via its topic, and several users can poll the data from the same topic (see [fink-client](https://github.com/astrolabsoftware/fink-client)). Note that if the filters reduce the size of the stream, they do not filter the content of alerts, i.e. you will receive the full information of alerts distributed.

Below we summarise the available Fink topics:

| Name | Link | Contents |
|:--------|:-------|:--------|
| `snialike` | [snialike](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_snlike/filter.py) | Return alerts considered as SN-Ia candidate |
| `<simbad-type>` | Example [rrlyr](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_rrlyr/filter.py) | See left column of http://simbad.u-strasbg.fr/simbad/sim-display?data=otypes for more information |

Over time, there will be more topics available - and feel free to propose new topics! The topic data is stored for 4 days after creation (i.e. you can access alert data up to 4 days after it has been emitted).
