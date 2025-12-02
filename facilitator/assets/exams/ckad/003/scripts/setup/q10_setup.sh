#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q10 >/dev/null 2>&1 || kubectl create ns ckad-q10
mkdir -p /opt/course/exam3/q10

