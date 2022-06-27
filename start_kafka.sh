#!/bin/bash

set -euo pipefail

KAFKA_PATCH_PREFIX="KAFKA_CFG_"
SERVER_PROPERTIES_PATH="$KAFKA_HOME/config/server.properties"
FINAL_SERVER_PROPERTIES_PATH="$SERVER_PROPERTIES_PATH.final"

patch_kafka_config() {
  if [[ -f "$FINAL_SERVER_PROPERTIES_PATH" ]]; then
    echo "Final configuration already exists, skipping patching..."
    return
  fi

  cp "$SERVER_PROPERTIES_PATH" "$FINAL_SERVER_PROPERTIES_PATH"
  printf "\n\n############################# Docker KAFKA_CFG overrides #############################\n\n" >> "$FINAL_SERVER_PROPERTIES_PATH"

  echo "log.dirs=/data" >> "$FINAL_SERVER_PROPERTIES_PATH"

  while IFS='=' read -r -d '' name value; do
    if [[ "$name" =~ ^"$KAFKA_PATCH_PREFIX" ]]; then
        local kafka_name
        kafka_name=$(echo "${name:${#KAFKA_PATCH_PREFIX}}" | tr '[:upper:]' '[:lower:]' | tr '_' '.')

        echo "Patching $kafka_name config..."
        echo "$kafka_name=$value" >> "$FINAL_SERVER_PROPERTIES_PATH"
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
  kafka-storage.sh format --config "$FINAL_SERVER_PROPERTIES_PATH" --cluster-id "$cluster_id" --ignore-formatted
}

patch_kafka_config
prepare_kafka
exec "kafka-server-start.sh" "$FINAL_SERVER_PROPERTIES_PATH"
