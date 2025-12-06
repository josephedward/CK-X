#!/usr/bin/env bash
set -euo pipefail
ns=services-curl

# Ensure there is no leftover tmp pod (should be removed with --rm)
if kubectl -n "$ns" get pod tmp -o name >/dev/null 2>&1; then
  echo "tmp pod still exists" >&2
  exit 1
fi

# Best-effort: verify an event exists for a Pod named tmp in this namespace
# Field selectors work across many versions; if events are pruned, this may be empty.
if kubectl -n "$ns" get events --field-selector involvedObject.kind=Pod,involvedObject.name=tmp --no-headers 2>/dev/null | grep -q .; then
  exit 0
fi

echo "No evidence of temporary pod 'tmp' in events" >&2
exit 1

