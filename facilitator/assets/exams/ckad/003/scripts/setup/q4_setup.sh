#!/usr/bin/env bash
set -euo pipefail

# Q4 setup: seed Helm releases automatically when Helm + internet are available.
# - Always ensure output dir exists
# - Be idempotent: safe to rerun; don't duplicate resources
# - Do not mark as seeded if Helm/repo unavailable; try again on next run

OUT_DIR=/opt/course/exam3/q04
NS=helm
STUCK_NS=helm-stuck
PENDING_REL=internal-issue-report-pending

mkdir -p "$OUT_DIR"

# Ensure namespaces exist (no error if already present)
kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS" >/dev/null 2>&1 || true
kubectl get ns "$STUCK_NS" >/dev/null 2>&1 || kubectl create ns "$STUCK_NS" >/dev/null 2>&1 || true

# Seed only if helm is present; skip silently otherwise (script is idempotent and can be retried)
if command -v helm >/dev/null 2>&1; then
  # Ensure Bitnami repo exists and is updated
  if ! helm repo list 2>/dev/null | awk '{print $1}' | grep -qx "bitnami"; then
    helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null 2>&1 || true
  fi
  helm repo update >/dev/null 2>&1 || true

  # Install/upgrade baseline releases in helm namespace
  if ! helm -n "$NS" list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "internal-issue-report-apiv1"; then
    helm -n "$NS" upgrade --install internal-issue-report-apiv1 bitnami/nginx >/dev/null 2>&1 || true
  fi
  if ! helm -n "$NS" list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "internal-issue-report-apiv2"; then
    helm -n "$NS" upgrade --install internal-issue-report-apiv2 bitnami/nginx >/dev/null 2>&1 || true
  fi

  # Ensure/refresh a release stuck in pending-install across namespaces
  if helm ls -A 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$PENDING_REL"; then
    # Clean any existing state to guarantee pending-install on next run
    helm ls -A 2>/dev/null | awk -v rel="$PENDING_REL" 'NR>1 && $1==rel {print $2, $1}' | while read ns rel; do helm -n "$ns" uninstall "$rel" >/dev/null 2>&1 || true; done
  fi
  # Start a long-wait install with invalid image so it remains pending
  if ! helm ls -A 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$PENDING_REL"; then
    (
      helm -n "$STUCK_NS" upgrade --install "$PENDING_REL" bitnami/nginx \
        --set image.repository=ghcr.io/ckx/this-will-never-exist \
        --wait --timeout 24h >/dev/null 2>&1 || true
    ) &
  fi
fi
