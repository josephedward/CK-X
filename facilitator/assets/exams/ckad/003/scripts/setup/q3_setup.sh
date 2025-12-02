#!/usr/bin/env bash
set -euo pipefail
kubectl get ns jobs >/dev/null 2>&1 || kubectl create ns jobs
mkdir -p /opt/course/exam3/q03
