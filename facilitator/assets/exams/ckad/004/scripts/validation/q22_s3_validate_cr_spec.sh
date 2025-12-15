#!/usr/bin/env bash
# Q22.03 - CR spec matches requirements
# Points: 2

# Check if the CRD has the expected schema properties
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/../lib/common.sh"

# Check if CRD has scheduleTime property in schema
SCHEDULE_TIME=$(kubectl get crd backups.stable.example.com -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.scheduleTime}' 2>/dev/null)
if [ -z "$SCHEDULE_TIME" ]; then
    fail "CRD does not have scheduleTime property in schema"
fi

# Check if CRD has retentionDays property in schema
RETENTION_DAYS=$(kubectl get crd backups.stable.example.com -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.retentionDays}' 2>/dev/null)
if [ -z "$RETENTION_DAYS" ]; then
    fail "CRD does not have retentionDays property in schema"
fi

# Check if the custom resource has the expected structure
SPEC=$(kubectl get backup my-backup -n crds -o jsonpath='{.spec}' 2>/dev/null)
if [ -z "$SPEC" ]; then
    fail "Custom Resource spec is empty or missing"
fi

# Check if the custom resource spec contains scheduleTime
if [[ "$SPEC" != *"scheduleTime"* ]]; then
    fail "Custom Resource spec does not contain scheduleTime"
fi

# Check if the custom resource spec contains retentionDays
if [[ "$SPEC" != *"retentionDays"* ]]; then
    fail "Custom Resource spec does not contain retentionDays"
fi

ok "Custom Resource spec matches requirements with proper schema properties"
