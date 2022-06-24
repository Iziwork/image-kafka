FROM alpine:3.16 as builder

RUN apk --no-cache add bash=5.1.16-r2 curl=7.83.1-r1

ARG kafka_version
ARG scala_version
ARG kafka_tarball_sha512

COPY ./download_kafka.sh /usr/local/bin/download_kafka.sh
RUN download_kafka.sh "/opt/kafka" "$kafka_version" "$scala_version" "$kafka_tarball_sha512"

FROM eclipse-temurin:17-jre

RUN useradd -u 1000 -G 1000 kafka
USER kafka

ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

COPY ./start_kafka.sh /usr/local/bin/start_kafka.sh
COPY --from=builder "$KAFKA_HOME" "$KAFKA_HOME"

VOLUME ["/data"]

CMD ["start_kafka.sh"]
