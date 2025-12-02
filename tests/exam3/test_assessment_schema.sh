#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "$0")/../.." && pwd)"
assess="$root_dir/facilitator/assets/exams/ckad/003/assessment.json"
val_dir="$root_dir/facilitator/assets/exams/ckad/003/scripts/validation"
tmp_assess=$(mktemp)

# Sanitize potential stray control characters (e.g., \x02) that may appear from copy/paste
LC_ALL=C tr -d '\002' < "$assess" > "$tmp_assess"

command -v jq >/dev/null 2>&1 || { echo "jq is required for this test" >&2; exit 1; }

[ -f "$assess" ] || { echo "assessment.json not found" >&2; exit 1; }

len=$(jq '.questions | length' "$tmp_assess")
if [[ "$len" -ne 22 ]]; then
  echo "Expected 22 questions, found $len" >&2
  exit 1
fi

# Validate each question has required fields and scripts exist
for i in $(seq 0 21); do
  id=$(jq -r ".questions[$i].id" "$tmp_assess")
  ns=$(jq -r ".questions[$i].namespace" "$tmp_assess")
  mh=$(jq -r ".questions[$i].machineHostname" "$tmp_assess")
  qtext=$(jq -r ".questions[$i].question" "$tmp_assess")
  [ -n "$id" ] && [ -n "$ns" ] && [ -n "$mh" ] && [ -n "$qtext" ] || { echo "Missing fields in question index $i" >&2; exit 1; }

  # Check verification scripts exist
  vcount=$(jq ".questions[$i].verification | length" "$tmp_assess")
  for j in $(seq 0 $((vcount-1))); do
    script=$(jq -r ".questions[$i].verification[$j].verificationScriptFile" "$tmp_assess")
    [ -f "$val_dir/$script" ] || { echo "Missing validation script: $script (Q$id)" >&2; exit 1; }
  done
done

rm -f "$tmp_assess"
exit 0
