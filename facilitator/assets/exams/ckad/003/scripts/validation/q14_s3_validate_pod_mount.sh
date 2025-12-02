#!/usr/bin/env bash
set -euo pipefail
ns=secrets-cm
name=secret-handler
# Verify a volume mounts configMap secret2 at /tmp/secret2
mountPath=$(kubectl -n "$ns" get pod "$name" -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath=="/tmp/secret2")].mountPath}')
cmName=$(kubectl -n "$ns" get pod "$name" -o jsonpath='{.spec.volumes[?(@.name=="secret2")].configMap.name}')
test "$mountPath" = "/tmp/secret2" && test "$cmName" = "secret2"
