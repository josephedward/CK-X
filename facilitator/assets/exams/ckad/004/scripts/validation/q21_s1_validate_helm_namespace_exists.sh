#!/usr/bin/env bash
# Q21.01 - Namespace helm-operations exists
# Points: 2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../lib/common.sh"
if k_exists namespace helm-operations; then
  ok "Namespace helm-operations exists"
else
  fail "Namespace helm-operations not found"
fi
