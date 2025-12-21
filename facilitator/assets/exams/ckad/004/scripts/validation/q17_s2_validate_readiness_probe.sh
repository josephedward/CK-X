#!/usr/bin/env bash
# Q17.02 - Readiness probe configured (HTTP GET / on 80)
# Points: 4

NS="readiness-probes"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../lib/common.sh"
PROBE_PATH=$(jp pod ready-web "$NS" .spec.containers[0].readinessProbe.httpGet.path)
PORT=$(jp pod ready-web "$NS" .spec.containers[0].readinessProbe.httpGet.port)
if [[ "$PROBE_PATH" == "/" && "$PORT" == "80" ]]; then
  ok "Readiness probe HTTP GET /:80 configured"
else
  fail "Readiness probe not configured as expected (path=$PROBE_PATH, port=$PORT)"
fi
