#!/usr/bin/env bash
# Q22.4 - CRD is properly defined
# Points: 2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../lib/common.sh"

if k_exists crd backups.stable.example.com; then
    ok "CRD is properly defined"
else
    fail "CRD not properly defined"
fi
