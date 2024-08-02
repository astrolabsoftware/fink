## On the use of non-relational database

Apache HBase -> pas de schema

## Fields definition

### Prefix meaning (i:, d:, ...)

### Main table

used for objects only

### Auxilliary tables

all other endpoints

## Class definition

!!! info "What is a class in Fink?"
    The list of Fink class can be found at [https://fink-portal.org/api/v1/classes](https://fink-portal.org/api/v1/classes). We recommend also to read how the [classification scheme](/broker/classification) is built.

You can programmatically access the list of all the Fink classes using e.g.:

```bash
curl -H "Content-Type: application/json" -X GET \
    https://fink-portal.org/api/v1/classes -o finkclass.json
```
