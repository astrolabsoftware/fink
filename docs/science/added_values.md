# Fink alert added values

In addition to the information contained in the incoming raw alerts (see [ZTF alerts schema](https://zwickytransientfacility.github.io/ztf-avro-alert/) for example), Fink attached new information coming from the science modules. This information is in form of extra fields inside the alert packet, and you would access to it the same way as any other fields. Below we summarise the fields added by the Fink science modules:

| Field name | Type | Contents |
|:--------|:-------|:--------|
| `cdsxmatch` | string | Counterpart (cross-match) in the Simbad database |
| `rf_snia_vs_nonia` | float | Probability to be a SNe Ia based on Random Forest classifier (1 is SN Ia). Based on https://arxiv.org/abs/2111.11438 |
| `snn_snia_vs_nonia` | float | Probability to be a SNe Ia based on [SuperNNova](https://supernnova.readthedocs.io/en/latest/) classifier (1 is SN Ia). Based on https://arxiv.org/abs/1901.06384 |
| `snn_sn_vs_all` | float | Probability to be a SNe based on [SuperNNova](https://supernnova.readthedocs.io/en/latest/) classifier (1 is SNe). Based on https://arxiv.org/abs/1901.06384 |
| `mulens` | float | Probability score to be a microlensing event by [LIA](https://github.com/dgodinez77/LIA) |
| `roid` | int | Determine if the alert is a Solar System object |
| `rf_kn_vs_nonkn` | float | probability of an alert to be a kilonova using a Random Forest Classifier (binary classification). |

!!! note
    There has been a name change, starting from fink-science 0.5.0:
    `rfscore` was replaced by `rf_snia_vs_nonia`, and `knscore` was replaced by `rf_kn_vs_nonkn`.

!!! note
    There has been a type change, starting from fink-science 0.5.0:
    `mulens` is no more a struct, but a float.

Details can be found at [fink-science](https://github.com/astrolabsoftware/fink-science). Over time, there will be more added values available - and feel free to propose new modules!
