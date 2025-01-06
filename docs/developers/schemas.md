The different services in Fink serve data from different sources, hence the schemas can be different from one service to another. We list here the relevant schemas and data provenance per service.

## ZTF

<div class="grid cards" markdown>

-   __Science Portal__

    ---

    The [Science Portal](https://fink-portal.org) relies on a REST API that queries the Fink Database, which contains aggregated data organized into [column families](../services/search/definitions.md) based on data provenance. For more details, you can refer to the [DB schema](https://api.fink-portal.org/api/v1/schema).

-   __REST API__

    ---

    The [REST API](../services/search/getting_started.md) queries the Fink Database, which contains aggregated data organized into [column families](../services/search/definitions.md) based on data provenance. For more details, you can refer to the [DB schema](https://api.fink-portal.org/api/v1/schema).

-   __Livestream__

    ---

    The [Livestream service](../services/livestream.md) relies on the Fink Data Lake which is the concatenation of the [ZTF alert schema](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html) and Fink [added values](../broker/science_modules.md).


-   __Data Transfer__

    ---

    The [Data Transfer service](../services/data_transfer.md) relies on the Fink Data Lake which is the concatenation of the [ZTF alert schema](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html) and Fink [added values](../broker/science_modules.md).

</div>

Note that Fink Science modules and Fink filters rely on the same schema than the livestream and the Data Transfer services.

## Rubin/LSST

The latest Rubin alert schema can be found at [https://github.com/lsst/alert_packet/tree/main/python/lsst/alert/packet/schema](https://github.com/lsst/alert_packet/tree/main/python/lsst/alert/packet/schema). This constitutes the base for the Science modules.
