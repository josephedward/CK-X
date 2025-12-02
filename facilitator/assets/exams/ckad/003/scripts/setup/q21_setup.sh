#!/usr/bin/env bash
set -euo pipefail
kubectl get ns ckad-p2 >/dev/null 2>&1 || kubectl create ns ckad-p2
kubectl -n ckad-p2 get sa sa-sun-deploy >/dev/null 2>&1 || kubectl -n ckad-p2 create sa sa-sun-deploy
mkdir -p /opt/course/exam3/p2

