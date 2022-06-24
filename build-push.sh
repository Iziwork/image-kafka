#!/bin/bash

set -euo pipefail

PLATFORMS="linux/amd64,linux/arm/v7,linux/arm64"

build_push() {
  local image_name="$1"
  local kafka_version="$2"
  local scala_version="$3"

  local docker_tags
  docker_tags=$(get_docker_tags "$image_name" "$kafka_version")

  # shellcheck disable=SC2086
  docker buildx build \
    --push \
    --platform "$PLATFORMS" \
    --build-arg kafka_version="$kafka_version" \
    --build-arg scala_version="$scala_version" \
    $docker_tags \
    .
}

get_docker_tags() {
  local image_name="$1"
  local kafka_version="$2"

  local major_minor
  major_minor=$(echo "$kafka_version" | cut -d '.' -f -2)

  local major
  major=$(echo "$kafka_version" | cut -d '.' -f 1)

  echo "--tag latest --tag $image_name:$kafka_version --tag $image_name:$major_minor --tag $image_name:$major"
}

image_name="$1"
kafka_version="$2"
scala_version="$3"

build_push "$image_name" "$kafka_version" "$scala_version"
