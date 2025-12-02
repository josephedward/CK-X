#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_dir/facilitator/assets/exams" || exit 1

fail=0
while IFS= read -r -d '' cfg; do
  rel_cfg="${cfg#./}"
  # Get dir of config file, relative to the 'exams' dir
  cfg_dir=$(dirname "$rel_cfg")

  answers_path=$(jq -r '.answers // empty' "$cfg" 2>/dev/null || echo "")
  if [[ -z "$answers_path" ]]; then
    echo "[ERROR] No 'answers' key in $rel_cfg"
    fail=1
    continue
  fi

  # Determine full path based on the same logic as examService.js
  full_path=""
  if [[ "$answers_path" == /* ]]; then # Absolute path
    full_path="$answers_path"
  elif [[ "$answers_path" == "assets/"* || "$answers_path" == "facilitator/"* ]]; then # Repo-relative
    full_path="$root_dir/$answers_path"
  else # Relative to asset path
    full_path="$root_dir/facilitator/assets/exams/$cfg_dir/$answers_path"
  fi

  if [[ ! -f "$full_path" ]]; then
    echo "[ERROR] Missing answers file: $answers_path (referenced by $rel_cfg, checked $full_path)"
    fail=1
  else
    echo "[OK] $answers_path (from $rel_cfg)"
  fi
done < <(find . -type f -name config.json -print0)

exit $fail

