# ZTF alert stream

To design the broker and test the science modules while waiting for LSST data, we use the [ZTF](https://www.ztf.caltech.edu/) alert stream. The ZTF alert data is publicly available through their [web portal](https://ztf.uw.edu/alerts/public/).

## Alert format

ZTF alert data serialisation is done using [Apache Avro](http://avro.apache.org/). You can find all information about ZTF alerts [here](https://zwickytransientfacility.github.io/ztf-avro-alert/).

Typically, to design your science module you have three main observables: the sky location (ra, dec), the light-curve (1 month history in g, r, i filter bands), and the 30x30 pixels cutouts (other fields are described [here](https://zwickytransientfacility.github.io/ztf-avro-alert/schema.html)).
