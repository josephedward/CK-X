#!/bin/bash

# Validate that the network-policy namespace exists
NS=$(kubectl get namespace network-policy -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$NS" == "network-policy" ]]; then
    # Namespace exists
    exit 0
else
    # Namespace does not exist
    echo "Namespace 'network-policy' does not exist"
    exit 1
fi 