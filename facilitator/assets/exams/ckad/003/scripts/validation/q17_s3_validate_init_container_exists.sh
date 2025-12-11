#!/usr/bin/env bash
set -euo pipefail
# Ensures the 'init-con' init container exists
kubectl -n init-container get deploy test-init-container -o jsonpath='{.spec.template.spec.initContainers[*].name}' | grep -q "init-con"