#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q05 >/dev/null 2>&1 || kubectl create ns ckad-q05
kubectl -n ckad-q05 get sa neptune-sa-v2 >/dev/null 2>&1 || kubectl -n ckad-q05 create sa neptune-sa-v2
mkdir -p /opt/course/exam3/q05

