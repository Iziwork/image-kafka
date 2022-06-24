#!/bin/bash

set -euo pipefail

KAFKA_PATCH_PREFIX="KAFKA_CFG_"
SERVER_PROPERTIES_PATH="$KAFKA_HOME/config/server.properties"
PATCHED_SERVER_PROPERTIES_PATH="$SERVER_PROPERTIES_PATH.patched"

patch_kafka_config() {
  cp "$SERVER_PROPERTIES_PATH" "$PATCHED_SERVER_PROPERTIES_PATH"
  printf "\n\n############################# Docker KAFKA_CFG overrides #############################\n\n" >> "$PATCHED_SERVER_PROPERTIES_PATH"

  echo "log.dirs=/data" >> "$PATCHED_SERVER_PROPERTIES_PATH"

  while IFS='=' read -r -d '' name value; do
    if [[ "$name" =~ ^"$KAFKA_PATCH_PREFIX" ]]; then
        local kafka_name
        kafka_name=$(echo "${name:${#KAFKA_PATCH_PREFIX}}" | tr '[:upper:]' '[:lower:]' | tr '_' '.')

        echo "Patching $kafka_name config..."
        echo "$kafka_name=$value" >> "$PATCHED_SERVER_PROPERTIES_PATH"
    fi
  done < <(env -0)
}

prepare_kafka() {
  if [[ -z ${KAFKA_ENABLE_KRAFT+x} ]]; then
    echo "KRaft is not enabled, skipping formatting..."
    return
  fi

  echo "KRaft is enabled, ensuring storage directory is formatted..."
  local cluster_id
  cluster_id=$(kafka-storage.sh random-uuid)
  kafka-storage.sh format --config "$PATCHED_SERVER_PROPERTIES_PATH" --cluster-id "$cluster_id" --ignore-formatted
}

patch_kafka_config
prepare_kafka
exec "kafka-server-start.sh" "$PATCHED_SERVER_PROPERTIES_PATH"
