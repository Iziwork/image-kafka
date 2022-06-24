FROM alpine:3.16 as builder

RUN apk add --no-cache bash curl

ARG kafka_version
ARG scala_version

COPY ./download_kafka.sh .
RUN ./download_kafka.sh "/opt/kafka" "$kafka_version" "$scala_version"

FROM eclipse-temurin:17-jre

ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

COPY ./start_kafka.sh .
COPY --from=builder "$KAFKA_HOME" "$KAFKA_HOME"

VOLUME ["/data"]

ENTRYPOINT ["./start_kafka.sh"]
