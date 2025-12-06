#!/usr/bin/env bash
set -euo pipefail
ns=services-curl
main_pod=project-plt-6cc-api

# Legacy fast-path: if a 'tmp' pod event exists, accept
if kubectl -n "$ns" get events --field-selector involvedObject.kind=Pod,involvedObject.name=tmp --no-headers 2>/dev/null | grep -q .; then
  exit 0
fi

# Accept evidence of any ephemeral pod usage:
# 1) A completed (temporary) pod exists (not the main app pod)
if kubectl -n "$ns" get pods --no-headers 2>/dev/null | awk -v m="$main_pod" '$1!=m && $3=="Completed"{found=1} END{exit (found?0:1)}'; then
  exit 0
fi

# 2) An event exists for a pod that no longer exists (likely created with --rm)
current=$(kubectl -n "$ns" get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null || true)
while read -r name; do
  [ -z "$name" ] && continue
  [ "$name" = "$main_pod" ] && continue
  if ! printf '%s\n' "$current" | grep -qx "$name"; then
    exit 0
  fi
done < <(kubectl -n "$ns" get events --field-selector involvedObject.kind=Pod -o jsonpath='{range .items[*]}{.involvedObject.name}{"\n"}{end}' 2>/dev/null || true)

echo "No evidence of a temporary pod (any name) used for curl" >&2
exit 1
