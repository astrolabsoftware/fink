# ZTF alert stream

To design the broker and test the science modules while waiting for LSST data, we use the [ZTF](https://www.ztf.caltech.edu/) alert stream. The ZTF alert data (full, unfiltered, 5-sigma alert stream) is publicly available through their [web portal](https://ztf.uw.edu/alerts/public/), and you can find all information about ZTF alerts [here](https://zwickytransientfacility.github.io/ztf-avro-alert/).

## Alert format

ZTF alert data serialisation is done using [Apache Avro](http://avro.apache.org/).  Typically, to design your science module you have three main observables:

* the sky location (ra, dec)
* the light-curve (up to 1 month history in g, r, i filter bands)
* 30x30 pixels cutouts (observation, template, and difference image)

Other fields are described [here](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html).
