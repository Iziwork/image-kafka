FROM alpine:3.20 as builder

RUN apk --no-cache add bash curl

ARG kafka_version
ARG scala_version
ARG kafka_tarball_sha512

COPY ./download_kafka.sh /usr/local/bin/download_kafka.sh
RUN download_kafka.sh "/opt/kafka" "$kafka_version" "$scala_version" "$kafka_tarball_sha512"

FROM eclipse-temurin:17-jre

RUN useradd -u 1000 kafka

ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

RUN apt-get update && \
    apt-get install -y netcat && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=kafka ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chown=kafka ./start_kafka.sh /usr/local/bin/start_kafka.sh
COPY --chown=kafka --from=builder "$KAFKA_HOME" "$KAFKA_HOME"

VOLUME ["/data"]

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start_kafka.sh"]
