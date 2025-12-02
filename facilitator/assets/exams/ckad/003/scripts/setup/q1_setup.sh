#!/usr/bin/env bash
set -euo pipefail

# Namespace isolation (optional for Q1)
kubectl get ns ckad-q01 >/dev/null 2>&1 || kubectl create ns ckad-q01

mkdir -p /opt/course/exam3/q01

