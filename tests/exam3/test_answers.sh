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

base_dir="$(dirname "$cfg")"
candidates=(
  "$base_dir/$answers_path"
  "$root_dir/$answers_path"
  "$root_dir/facilitator/$answers_path"
)

for p in "${candidates[@]}"; do
  if [[ -f "$p" ]]; then
    rel="${p#$root_dir/}"
    echo "[OK] $rel"
    exit 0
  fi
done

echo "Missing answers file: $answers_path (checked candidates: ${candidates[*]})" >&2
exit 1
