#!/bin/bash

set -euo pipefail

TMP_DIR=$(mktemp -d -t "kafka.XXXXXX")

download_kafka() {
  local install_dir="$1"
  local kafka_version="$2"
  local scala_version="$3"

  local base_url="https://dlcdn.apache.org/kafka/$kafka_version"

  local tarball_filename="kafka_$scala_version-$kafka_version.tgz"
  local tarball_url="$base_url/$tarball_filename"
  local tarball_dest="$TMP_DIR/$tarball_filename"

  local sha512_filename="$tarball_filename.sha512"
  local sha512_url="$base_url/$sha512_filename"
  local sha512_dest="$TMP_DIR/$sha512_filename"

  echo "Downloading Kafka..."
  curl --fail --output "$tarball_dest" "$tarball_url"
  curl --fail --output "$sha512_dest" "$sha512_url"

  echo "Validating integrity..."
  local sha512_content
  sha512_content=$(cat "$sha512_dest")
  local sha512_hash
  sha512_hash=$(echo "$sha512_content" | cut -d ' ' -f 2- | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
  pushd "$TMP_DIR" > /dev/null
  echo "$sha512_hash  $tarball_filename" | sha512sum -c -
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

download_kafka "$install_dir" "$kafka_version" "$scala_version"
