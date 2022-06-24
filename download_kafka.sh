#!/bin/bash

set -euo pipefail

TMP_DIR=$(mktemp -d -t "kafka.XXXXXX")

download_kafka() {
  local install_dir="$1"
  local kafka_version="$2"
  local scala_version="$3"
  local kafka_tarball_sha512="$4"

  local tarball_filename="kafka_$scala_version-$kafka_version.tgz"
  local tarball_url="https://dlcdn.apache.org/kafka/$kafka_version/$tarball_filename"
  local tarball_dest="$TMP_DIR/$tarball_filename"

  echo "Downloading Kafka..."
  curl --fail --output "$tarball_dest" "$tarball_url"

  echo "Validating integrity..."
  pushd "$TMP_DIR" > /dev/null
  echo "$kafka_tarball_sha512  $tarball_filename" | sha512sum -c -
  popd > /dev/null

  echo "Extracting Kafka..."
  rm -rf "$install_dir"
  mkdir -p "$install_dir"
  tar -xzf "$tarball_dest" --strip-components 1 -C "$install_dir"
}

cleanup() {
  echo "Cleaning up..."
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

install_dir="$1"
kafka_version="$2"
scala_version="$3"
kafka_tarball_sha512="$4"

download_kafka "$install_dir" "$kafka_version" "$scala_version" "$kafka_tarball_sha512"
