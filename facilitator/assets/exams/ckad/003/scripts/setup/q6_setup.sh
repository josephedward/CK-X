#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-q06 >/dev/null 2>&1 || kubectl create ns ckad-q06
mkdir -p /opt/course/exam3/q06

