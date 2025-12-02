#!/usr/bin/env bash
set -euo pipefail

# Q4 setup: prepare workspace and conditionally seed Helm releases if available.
# - Always ensure output dir exists
# - Do not hard fail if Helm or repo is unavailable
# - Only seed once; avoid re-installing after student deletes releases

OUT_DIR=/opt/course/exam3/q04
NS=ckad-q04
SEED_MARKER="$OUT_DIR/.seeded"

mkdir -p "$OUT_DIR"

# Ensure namespace exists for helm seeding when helm is available
kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS" >/dev/null 2>&1 || true

# If already seeded once, do nothing (idempotent and non-destructive post-deletion)
if [ -f "$SEED_MARKER" ]; then
  exit 0
fi

# Seed only if helm is present; skip silently otherwise
if command -v helm >/dev/null 2>&1; then
  # Always use Bitnami for predictability
  if ! helm repo list 2>/dev/null | awk '{print $1}' | grep -qx "bitnami"; then
    helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null 2>&1 || true
  fi
  helm repo update >/dev/null 2>&1 || true

  # Best-effort install of baseline releases from Bitnami
  helm -n "$NS" upgrade --install internal-issue-report-apiv1 bitnami/nginx >/dev/null 2>&1 || true
  helm -n "$NS" upgrade --install internal-issue-report-apiv2 bitnami/nginx >/dev/null 2>&1 || true
fi

# Mark as seeded to avoid re-doing the above on reruns
touch "$SEED_MARKER"
