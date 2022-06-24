#!/bin/bash

set -euo pipefail

chown -R kafka /data
exec runuser -u kafka "$@"
