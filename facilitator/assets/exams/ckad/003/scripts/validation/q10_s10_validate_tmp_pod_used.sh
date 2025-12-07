#!/usr/bin/env bash
set -euo pipefail
ns=services-curl
main_pod=project-plt-6cc-api

# 0) Infer from nginx access log: client IP should be a Pod IP in ns (and not main pod)
log_file=/opt/course/exam3/q10/service_test.log
if [ -s "$log_file" ]; then
  client_ip=$(awk '/GET \/( |HTTP\/)/{ip=$1} END{print ip}' "$log_file" | sed -n '1p')
  if printf '%s' "$client_ip" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    main_ip=$(kubectl -n "$ns" get pod "$main_pod" -o jsonpath='{.status.podIP}' 2>/dev/null || true)
    # Build list of pod IPs (name ip)
    if pod_map=$(kubectl -n "$ns" get pods -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.podIP}{"\n"}{end}' 2>/dev/null); then
      if printf '%s\n' "$pod_map" | awk -v ip="$client_ip" -v m="$main_pod" -v mip="$main_ip" '($2==ip) && ($1!=m) && (ip!="") && (ip!=mip){found=1} END{exit (found?0:1)}'; then
        exit 0
      fi
    fi
  fi
fi

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
