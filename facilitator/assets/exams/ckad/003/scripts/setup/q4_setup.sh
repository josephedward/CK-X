#!/usr/bin/env bash
set -euo pipefail

# Q4 setup: prepare workspace and conditionally seed Helm releases if available.
# - Always ensure output dir exists
# - Do not hard fail if Helm or repo is unavailable
# - Only seed once; avoid re-installing after student deletes releases

OUT_DIR=/opt/course/exam3/q04
NS=helm
STUCK_NS=helm-stuck
PENDING_REL=internal-issue-report-pending
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

  # Baseline releases in helm
  if ! helm -n "$NS" list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "internal-issue-report-apiv1"; then
    helm -n "$NS" upgrade --install internal-issue-report-apiv1 bitnami/nginx >/dev/null 2>&1 || true
  fi
  if ! helm -n "$NS" list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "internal-issue-report-apiv2"; then
    helm -n "$NS" upgrade --install internal-issue-report-apiv2 bitnami/nginx >/dev/null 2>&1 || true
  fi

  # Create a separate namespace for a pending-install release users must find with `helm ls -A`
  kubectl get ns "$STUCK_NS" >/dev/null 2>&1 || kubectl create ns "$STUCK_NS" >/dev/null 2>&1 || true

  # If a previous attempt exists (failed/deployed), clean it up to ensure pending state fresh on first seed
  if helm -A list 2>/dev/null | awk 'NR>1{print $1, $2, $8}' | grep -q "^$PENDING_REL "; then
    # Uninstall from any namespace it exists in
    helm ls -A 2>/dev/null | awk -v rel="$PENDING_REL" 'NR>1 && $1==rel {print $2, $1}' | while read ns rel; do helm -n "$ns" uninstall "$rel" >/dev/null 2>&1 || true; done
  fi

  # Start a long wait install with an invalid image to keep status in pending-install; run in background
  if ! helm ls -A 2>/dev/null | awk 'NR>1 {print $1}' | grep -qx "$PENDING_REL"; then
    # Use an invalid repository so pods never pull; long timeout to keep it pending
    ( helm -n "$STUCK_NS" upgrade --install "$PENDING_REL" bitnami/nginx \
        --set image.repository=ghcr.io/ckx/this-will-never-exist \
        --wait --timeout 24h >/dev/null 2>&1 || true ) &
  fi
fi

# Mark as seeded to avoid re-doing the above on reruns
touch "$SEED_MARKER"
