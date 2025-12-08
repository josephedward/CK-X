#!/usr/bin/env bash
set -euo pipefail
ns=secrets-cm
name=secret-handler
# Verify a volume mounts ConfigMap "secret2" at /tmp/secret2 on any container

# Find all volumeMount names across all containers that use mountPath=/tmp/secret2
mountNames=$(kubectl -n "$ns" get pod "$name" -o jsonpath='{.spec.containers[*].volumeMounts[?(@.mountPath=="/tmp/secret2")].name}')

# If no mounts found, fail early
if [ -z "${mountNames}" ]; then
  exit 1
fi

# For any matching mount name, confirm the backing volume is a ConfigMap named "secret2"
for m in ${mountNames}; do
  cmNameForMount=$(kubectl -n "$ns" get pod "$name" -o jsonpath="{.spec.volumes[?(@.name==\"$m\")].configMap.name}")
  if [ "$cmNameForMount" = "secret2" ]; then
    exit 0
  fi
done

exit 1
