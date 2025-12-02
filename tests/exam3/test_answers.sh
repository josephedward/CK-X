#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "$0")/../.." && pwd)"

# Limit scope to exam3 only to avoid unrelated lab failures
cfg="$root_dir/facilitator/assets/exams/ckad/003/config.json"
answers_path=$(jq -r '.answers // empty' "$cfg")
if [[ -z "$answers_path" ]]; then
  echo "answers key missing in $cfg" >&2
  exit 1
fi
# First try path relative to repo root (as used in container)
full_path="$root_dir/$answers_path"
alt_full_path="$root_dir/facilitator/$answers_path"
if [[ -f "$full_path" ]]; then
  echo "[OK] $answers_path"
  exit 0
elif [[ -f "$alt_full_path" ]]; then
  echo "[OK] facilitator/$answers_path"
  exit 0
else
  echo "Missing answers file: $answers_path (checked: $full_path and $alt_full_path)" >&2
  exit 1
fi
