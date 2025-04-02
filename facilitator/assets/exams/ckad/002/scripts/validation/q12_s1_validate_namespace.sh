#!/bin/bash

# Validate that the storage namespace exists
NS=$(kubectl get namespace storage -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$NS" == "storage" ]]; then
    # Namespace exists
    exit 0
else
    # Namespace does not exist
    echo "Namespace 'storage' does not exist"
    exit 1
fi 