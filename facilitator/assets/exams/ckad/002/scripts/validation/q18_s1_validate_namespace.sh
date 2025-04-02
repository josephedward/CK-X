#!/bin/bash

# Validate that the pod-scheduling namespace exists
NS=$(kubectl get namespace pod-scheduling -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$NS" == "pod-scheduling" ]]; then
    # Namespace exists
    exit 0
else
    # Namespace does not exist
    echo "Namespace 'pod-scheduling' does not exist"
    exit 1
fi 