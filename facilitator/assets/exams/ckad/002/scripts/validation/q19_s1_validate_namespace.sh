#!/bin/bash

# Validate that the pod-networking namespace exists
NS=$(kubectl get namespace pod-networking -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$NS" == "pod-networking" ]]; then
    # Namespace exists
    exit 0
else
    # Namespace does not exist
    echo "Namespace 'pod-networking' does not exist"
    exit 1
fi 