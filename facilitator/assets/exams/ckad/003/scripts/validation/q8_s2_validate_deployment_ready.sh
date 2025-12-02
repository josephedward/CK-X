#!/usr/bin/env bash
set -euo pipefail
ns=ckad-q08
name=api-new-c32
desired=$(kubectl -n "$ns" get deploy "$name" -o jsonpath='{.spec.replicas}')
[ -z "$desired" ] && desired=1
ready=$(kubectl -n "$ns" get deploy "$name" -o jsonpath='{.status.readyReplicas}')
[ -z "$ready" ] && ready=0
updated=$(kubectl -n "$ns" get deploy "$name" -o jsonpath='{.status.updatedReplicas}')
[ -z "$updated" ] && updated=0
available=$(kubectl -n "$ns" get deploy "$name" -o jsonpath='{.status.availableReplicas}')
[ -z "$available" ] && available=0
test "$ready" = "$desired" && test "$updated" = "$desired" && test "$available" = "$desired"
