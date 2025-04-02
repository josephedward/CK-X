#!/bin/bash

# Validate if the pod 'sidecar-pod' exists in the 'troubleshooting' namespace and has two containers
POD_EXISTS=$(kubectl get pod sidecar-pod -n troubleshooting -o name 2>/dev/null)
CONTAINER_COUNT=$(kubectl get pod sidecar-pod -n troubleshooting -o jsonpath='{.spec.containers}' 2>/dev/null | jq '. | length')

if [ -z "$POD_EXISTS" ]; then
    echo "Error: Pod 'sidecar-pod' does not exist in namespace 'troubleshooting'"
    exit 1
fi

if [ "$CONTAINER_COUNT" -eq "2" ]; then
    echo "Success: Pod 'sidecar-pod' exists and has two containers"
    
    # Verify container names and images
    NGINX_CONTAINER=$(kubectl get pod sidecar-pod -n troubleshooting -o jsonpath='{.spec.containers[?(@.image=="nginx")].name}' 2>/dev/null)
    BUSYBOX_CONTAINER=$(kubectl get pod sidecar-pod -n troubleshooting -o jsonpath='{.spec.containers[?(@.image=="busybox")].name}' 2>/dev/null)
    
    if [ -n "$NGINX_CONTAINER" ] && [ -n "$BUSYBOX_CONTAINER" ]; then
        echo "Success: Pod has both nginx and busybox containers"
        exit 0
    else
        echo "Error: Pod does not have the required container images (nginx and busybox)"
        echo "Found containers with images: $(kubectl get pod sidecar-pod -n troubleshooting -o jsonpath='{.spec.containers[*].image}' 2>/dev/null)"
        exit 1
    fi
else
    echo "Error: Pod 'sidecar-pod' does not have two containers. Found: $CONTAINER_COUNT containers"
    exit 1
fi 