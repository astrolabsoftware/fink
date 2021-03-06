# Fink releases

Release notes can be accessed via the links:

### Aug 27 2020 [0.7.0](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.7.0)
- [HBase] structure change (#388)
- Broadcast microlensing models to executors (#391)
- Allow easy data reprocessing (#392)
- [Science] Update science part according to fink-science 0.3.6 (SuperNNova, asteroids, nalerthist) (#394
### Jun 09 2020 [0.6.0](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.6.0)
- Database
    - New partitioning strategy (#363)
    - [Minor] Add night date in the merge job name. (#371)
    - [Merge] Use a fix basepath and add YYYY in the partition tree (#373)
    - Remove topic column, and rename ts_jd into timestamp (#377)
    - [Parquet] Add library versions to the data (#382)
- Stream2raw
    - Decode simulated data and ZTF data simultaneously (#367)
    - Add support for kerberised Kafka (#369)
- Science module & filters
    - [Science module] Microlensing (#358)
    - Update raw2science with new fink-science release (#375)
    - Add the asteroid catcher module (#379)
- Science portal
    - [Science Portal] Push a schema row while updating the science portal  (#356)
    - Remove ra_dec from the rowkey, and add new added values from the broker (#384)
- Misc
    - Update the README with GSoC 2020 news (#359)
    - Add Fink logo in the README  (#361)
### Apr 28 2020 [0.5.0](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.5.0)
- General
    - Add Dockerfile (#315 )
- Science module & filters
    - Add SN classification based on Random Forest (#319)
    - Add new filter snialike (#324)
    - Register new topic snialike on the CI (#330)
- Science portal
    - [Science portal] Ingest science data to HBase (#351)
- Schema
    - Update alert schemas: ZTF 3.3 and Fink 0.1 (#317)
    - Push new Fink schema version in the documentation (#321)
    - Note on live vs simulation mode for distribution schema (#338)
- Misc
    - Bump hbase version to 2.2.3 (#326)
    - fix broken link and update news in the README (#332)
    - Upgrade Spark versions in the travis configuration script (#335)
    - add missing ${EXTRA_SPARK_CONFIG} for the distribution job  (#337)
    - [Clean] remove unused classification module & bump HBase version (#346)
### Nov 26 2019 [0.4.0](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.4.0)
### Nov 25 2019 [0.3.0](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.3.0)
### Jul 04 2019 [0.2.1](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.2.1)
### Jun 12 2019 [0.2.0](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.2.0)
### Apr 30 2019 [0.1.1](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.1.1)
### Mar 25 2019 [0.1.0](https://github.com/astrolabsoftware/fink-broker/releases/tag/0.1.0)
