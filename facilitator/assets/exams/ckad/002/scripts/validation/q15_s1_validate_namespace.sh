#!/bin/bash

# Validate that the resource-management namespace exists
NS=$(kubectl get namespace resource-management -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$NS" == "resource-management" ]]; then
    # Namespace exists
    exit 0
else
    # Namespace does not exist
    echo "Namespace 'resource-management' does not exist"
    exit 1
fi 