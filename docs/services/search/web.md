# Science Portal

The Science Portal is a web application ([https://fink-portal.org](https://fink-portal.org)) to query and visualise Fink processed data. You can run simple queries and quickly display results. After each night, the alert data are aggregated and pushed to HBase tables. This means that you will not only access alert data, but _object_ data, that is all the alerts emitted from day zero for a given object on the sky will be available directly (while in individual alert packet only 30 days of data in the past is available).

## How to use it?

![1](/img/science_portal_annotated.png)
_A: Select the type of queries to execute. B: enter the query to run. C: get help on how to formulate your query. D: menu containing several links to other parts of the portal, including a link to the API and the statistics page._

![1](/img/object-annotated.png)
_A: Summary properties for the object. B: Complete light-curve of the object. The users can change units to display difference magnitude, DC magnitude, or DC apparent flux as a function of time. Filter bands are shown in different colours. C: Additional information such as the cutouts from the last alert packet of this object (click on the button to enlarge), alert packet data, closest sources from external catalogues, or how to download and share data. D: Interactive Aladin view of the object with the PanSTARRS-DR1 image centred at the position of the latest alert. E: Tabs to trigger different views of the object. The views focus on specific aspect of the data (such as the evolution of classification module scores for Supernovae detection) and the users can perform data fit based on pre-loaded models (e.g. variable stars, microlensing). New features and new views are regularly added based on our community feedback. As of March 2023, the Science Portal gives access to more than 110 million ZTF alerts processed by Fink._

You can also find information about the statistics on this [page](https://fink-broker.org/2021-12-01-statistics/).
