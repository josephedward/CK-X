#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(pwd)

find "${ROOT_DIR}/facilitator/assets/exams" -name "config.json" -print0 | while IFS= read -r -d $'
' FILE; do
  ORIGINAL_ANS_PATH=$(jq -r ".answers" "$FILE")
  NEW_ANS_PATH="answers.md"
  if [[ "$ORIGINAL_ANS_PATH" != "$NEW_ANS_PATH" ]]; then
    echo "Changing $FILE: $ORIGINAL_ANS_PATH -> $NEW_ANS_PATH"
    jq ".answers = \"$NEW_ANS_PATH\"" "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
  fi
done
