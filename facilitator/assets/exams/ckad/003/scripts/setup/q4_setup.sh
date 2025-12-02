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
KCONF="${KUBECONFIG:-/home/candidate/.kube/kubeconfig}"

mkdir -p "$OUT_DIR"

# Ensure namespaces exist (no error if already present)
kubectl --kubeconfig "$KCONF" get ns "$NS" >/dev/null 2>&1 || kubectl --kubeconfig "$KCONF" create ns "$NS" >/dev/null 2>&1 || true
kubectl --kubeconfig "$KCONF" get ns "$STUCK_NS" >/dev/null 2>&1 || kubectl --kubeconfig "$KCONF" create ns "$STUCK_NS" >/dev/null 2>&1 || true

# Seed only if helm is present; skip silently otherwise (script is idempotent and can be retried)
if command -v helm >/dev/null 2>&1; then
  # Ensure Bitnami repo exists and is updated
  if ! helm --kubeconfig "$KCONF" repo list 2>/dev/null | awk '{print $1}' | grep -qx "bitnami"; then
    helm --kubeconfig "$KCONF" repo add bitnami https://charts.bitnami.com/bitnami >/dev/null 2>&1 || true
  fi
  helm --kubeconfig "$KCONF" repo update >/dev/null 2>&1 || true

  # Install/upgrade baseline releases in helm namespace
  if ! helm --kubeconfig "$KCONF" -n "$NS" list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "internal-issue-report-apiv1"; then
    helm --kubeconfig "$KCONF" -n "$NS" upgrade --install internal-issue-report-apiv1 bitnami/nginx >/dev/null 2>&1 || true
  fi
  if ! helm --kubeconfig "$KCONF" -n "$NS" list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "internal-issue-report-apiv2"; then
    helm --kubeconfig "$KCONF" -n "$NS" upgrade --install internal-issue-report-apiv2 bitnami/nginx >/dev/null 2>&1 || true
  fi

  # Ensure/refresh a release stuck in pending-install across namespaces
  if helm --kubeconfig "$KCONF" ls -A 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$PENDING_REL"; then
    # Uninstall from any namespace it exists in
    helm --kubeconfig "$KCONF" ls -A 2>/dev/null | awk -v rel="$PENDING_REL" 'NR>1 && $1==rel {print $2, $1}' | while read ns rel; do helm --kubeconfig "$KCONF" -n "$ns" uninstall "$rel" >/dev/null 2>&1 || true; done
  fi

  # Build a tiny local chart that deliberately blocks install via a pre-install hook
  # This guarantees Helm shows status "pending-install" while the hook runs.
  CHART_DIR=/tmp/q4-pending-chart
  mkdir -p "$CHART_DIR/templates"
  cat > "$CHART_DIR/Chart.yaml" <<'CHART'
apiVersion: v2
name: pending-stuck
description: Chart that blocks install using a long-running pre-install hook
type: application
version: 0.1.0
appVersion: "1.0.0"
CHART
  cat > "$CHART_DIR/templates/preinstall-job.yaml" <<'TPL'
apiVersion: batch/v1
kind: Job
metadata:
  name: preinstall-blocker
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: blocker
          image: busybox:1.36
          command: ["/bin/sh","-c","sleep 86400"]
  backoffLimit: 0
TPL

  # Kick off install in background and disown so it remains pending-install
  if ! helm --kubeconfig "$KCONF" ls -A 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$PENDING_REL"; then
    nohup helm --kubeconfig "$KCONF" -n "$STUCK_NS" upgrade --install "$PENDING_REL" "$CHART_DIR" \
      >/tmp/q4_pending_helm.log 2>&1 & disown || true
  fi
fi
