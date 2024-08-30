## On the use of non-relational database

The data accessible from the REST API is stored in tables within the Apache HBase database. HBase is a non-relational database (i.e., it is not SQL-like). This has many advantages, notably that it does not rely on a fixed schema, allowing for easy schema migration. However, this also means that we must handle the description of the data ourselves when you run a query

To give you a more practical view, a long-lived variable object that emits alerts for years will consist of alert data with different fields: some fields may have been created, while others may have been deleted over the course of the event. This is handled at the query runtime.

## Fields definition

!!! info "What are the available fields in Fink?"
    The list of available fields through the API can be found at [https://fink-portal.org/api/v1/columns](https://fink-portal.org/api/v1/columns).

    You can programmatically access the list of all the fields using e.g.:

    ```bash
    curl -H "Content-Type: application/json" -X GET \
        https://fink-portal.org/api/v1/columns -o finkcolumns.json
    ```

### Prefix meaning (i:, d:, ...)

The fields are all prefixed with a letter determining the provenance of the data:

- `i:` original data from ZTF ([schema](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html))
- `d:` added values from [Fink Science modules](../../broker/science_modules.md) ([schema](https://fink-portal.org/api/v1/columns))
- `v:` added values from Fink generated at the query runtime ([schema](https://fink-portal.org/api/v1/columns))
- `b:` cutout data ([schema](https://fink-portal.org/api/v1/columns))

These are called column families.

### Main table

The main table (over 10TB and 200 million rows as of 2024) contains aggregated alert data (aka object data), and it is indexed over ZTF object ID and emission time. It contains all fields (`i:`, `d:`, ...).

### Auxilliary tables

Because HBase table have a unique index column, the main table is not great to run queries relying on other information than ID and time. Therefore, we built auxiliary tables that are indexed along different type of information (position, class, ...). To avoid data duplication, these tables contain less fields than the main table, and you will often have only a subset of all fields when running a query. In that case you will need to query the database in two steps (see e.g. the example in the [conesearch](conesearch.md)).

## Class definition

!!! info "What are the available astronomical classes in Fink?"
    The list of Fink class can be found at [https://fink-portal.org/api/v1/classes](https://fink-portal.org/api/v1/classes). We recommend also to read how the [classification scheme](/broker/classification) is built.

    You can programmatically access the list of all the Fink classes using e.g.:

    ```bash
    curl -H "Content-Type: application/json" -X GET \
        https://fink-portal.org/api/v1/classes -o finkclass.json
    ```
