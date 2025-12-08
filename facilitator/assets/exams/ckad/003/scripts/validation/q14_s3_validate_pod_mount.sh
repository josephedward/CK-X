#!/usr/bin/env bash
set -euo pipefail
ns=secrets-cm
name=secret-handler
# Verify a volume mounts ConfigMap "secret2" at /tmp/secret2 for the first container
# 1) Find the volumeMount on the first container with the exact mountPath
mountPath=$(kubectl -n "$ns" get pod "$name" -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/secret2")].mountPath}')
mountName=$(kubectl -n "$ns" get pod "$name" -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/secret2")].name}')
# 2) Resolve the ConfigMap name used by the corresponding volume (regardless of volume name)
cmNameForMount=$(kubectl -n "$ns" get pod "$name" -o jsonpath="{.spec.volumes[?(@.name==\"$mountName\")].configMap.name}")

test "$mountPath" = "/tmp/secret2" && test -n "$mountName" && test "$cmNameForMount" = "secret2"
