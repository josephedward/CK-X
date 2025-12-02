#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q13 >/dev/null 2>&1 || kubectl create ns ckad-q13
mkdir -p /opt/course/exam3/q13

