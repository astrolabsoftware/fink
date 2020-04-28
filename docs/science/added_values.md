# Fink alert added values

In addition to the information contained in the incoming raw alerts (see [ZTF alerts schema](https://zwickytransientfacility.github.io/ztf-avro-alert/) for example), Fink attached new information coming from the science module. This information is in form of extra fields inside the alert packet, and you would access to it the same way as any other fields. Below we summarise the fields added by the Fink science modules:

| Field | Type | Contents |
|:--------|:-------|:--------|
| `cdsxmatch` | string | Counterpart (cross-match) in the Simbad database |
| `rfscore` | float | Probability to be a SN Ia based on Random Forest classifier (1 is SN Ia). Based on https://arxiv.org/abs/1804.03765 |
| `mulens.class_1` | string | predicted class by [LIA](https://github.com/dgodinez77/LIA) for filter band g |
| `mulens.ml_score_1` | float | probability of an alert by [LIA](https://github.com/dgodinez77/LIA) (0 to 1) to be a microlensing event in filter band g using a Random Forest Classifier |
| `mulens.class_2` | string | predicted class by [LIA](https://github.com/dgodinez77/LIA) for filter band r |
| `mulens.ml_score_2` | float | probability of an alert by [LIA](https://github.com/dgodinez77/LIA) (0 to 1) to be a microlensing event in filter band r using a Random Forest Classifier |

Over time, there will be more added values available - and feel free to propose new modules!
