#!/usr/bin/env bash
set -euo pipefail
# validate type ClusterIP and port mapping 3333 -> 80
type=$(kubectl -n services-curl get svc project-plt-6cc-svc -o jsonpath='{.spec.type}')
port=$(kubectl -n services-curl get svc project-plt-6cc-svc -o jsonpath='{.spec.ports[0].port}')
targetPort=$(kubectl -n services-curl get svc project-plt-6cc-svc -o jsonpath='{.spec.ports[0].targetPort}')
test "$type" = "ClusterIP"
test "$port" = "3333"
test "$targetPort" = "80"
