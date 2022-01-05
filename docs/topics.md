# Fink topics

Each night, telescopes are sending raw alerts and the broker enriches these alerts by adding new information to identify interesting candidates for follow-up observations or further scientific processing. The raw incoming stream volume is huge, and each user might want to focus only on a subset of the stream. Hence the output of the broker contains filters that flag only particular parts of the stream to be distributed. Criteria are based on the [alert entries](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html): position, flux, properties, ... and [Fink added values](science/added_values.md).

Each stream subset from a particular filter is identified by a topic (ID). This stream can be accessed outside via its topic, and several users can poll the data from the same topic (see [fink-client](https://github.com/astrolabsoftware/fink-client)). Note that if the filters reduce the size of the stream, they do not filter the content of alerts, i.e. you will receive the full information of alerts distributed.

Below we summarise the default Fink topics:

| Name | Link | Contents |
|:--------|:-------|:--------|
| `early_sn_candidates` | [early_sn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_early_sn_candidates/filter.py) | Return alerts considered as Early SN-Ia candidates |
| `sn_candidates` | [sn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_sn_candidates/filter.py) | Return alerts considered as SN candidates |
| `sso_ztf_candidates` | [sso_ztf_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_sso_ztf_candidates/filter.py) | Return alerts with a counterpart in the Minor Planet Center database (Solar System Objects) |
| `sso_fink_candidates` | [sso_fink_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_fink_ztf_candidates/filter.py) | Return alerts considered as new Solar System Object candidates |
| `kn_candidates` | [kn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_kn_candidates/filter.py) | Return alerts considered as Kilonova candidates based on Machine Learning |
| `early_kn_candidates` | [early_kn_candidates](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_early_kn_candidates/filter.py) | Return alerts considered as Kilonova candidates based on crossmatch and property cuts |
| `simbad` | [simbad](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_simbad_candidates/filter.py) | Return all alerts with a counterpart in the SIMBAD database. See left column of http://simbad.u-strasbg.fr/simbad/sim-display?data=otypes for more information |
| `<single-simbad-type>` | Example [rrlyr](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_rrlyr/filter.py) | Return alerts matching one specific type in the SIMBAD database. See left column of http://simbad.u-strasbg.fr/simbad/sim-display?data=otypes for more information |
| `tracklet` | [tracklet](https://github.com/astrolabsoftware/fink-filters/blob/master/fink_filters/filter_tracklet_candidates/filter.py) | Return all alerts belonging to a tracklet (likely space debris or satellite glint) |

We also have many internal ones focusing on specific parts of the stream. Feel free also to propose new topics! The topic data is stored for 4 days after creation (i.e. you can access alert data up to 4 days after it has been emitted). See the [fink-client](fink-client.md) documentation for more information.
