# iziwork kafka image

We could not find a Kafka v3.3.1 image available for both amd64 and aarch64, so we made our own.

## Versioning

The images are tagged with the version of Kafka, the Scala version being ignored (we always use the latest available).

Example for Kafka 3.3.1 (if this is the latest): `latest, 3.3.1, 3.3, 3`.

## Configuration

The default `server.properties` Kafka configuration file is used, with the following patches applied:

* `log.dirs=/data`, and the image specifies a `/data` volume
* Any `KAFKA_CFG_<PROPERTY>` environment variable value. For example, `KAFKA_CFG_PROCESS_ROLES=broker,controller` would result in a `process.roles=broker,controller` appended to the configuration

If you want complete control over the Kafka configuration, just add a `/opt/kafka/config/server.properties.final` file and it will be used instead, without the above patches.

## Enable KRaft

If you want to use Kafka without Zookeeper, you can enable KRaft with the `KAFKA_ENABLE_KRAFT` (any value) environement variable.
On start, the image will make sure the storage directory is formatted (in other words, `kafka-storage.sh format` will be ran).

## Release

The image is released automatically on merge on `main`.
