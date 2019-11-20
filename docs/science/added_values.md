# Fink alert added values

In addition to the information contained in the incoming raw alerts (see [ZTF alerts](ztf_alerts.md) for example), Fink attached new information coming from the science module. This information is in form of extra fields inside the alert packet, and you would access to it the same way as any other fields, and you can use it to design a [distribution filter](../distribution/introduction.md).

Below we summarise the fields added by the Fink science modules:

### Top-level fields

| Field | Type | Contents |
|:--------|:-------|:--------|
| `cdsxmatch` | string | Counterpart (cross-match) in the Simbad database |
