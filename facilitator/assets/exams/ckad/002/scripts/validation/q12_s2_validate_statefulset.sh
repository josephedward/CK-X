#!/bin/bash

# Validate that the web StatefulSet exists
STATEFULSET=$(kubectl get statefulset web -n storage -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$STATEFULSET" == "web" ]]; then
    # StatefulSet exists, now check the specs
    
    # Check image
    IMAGE=$(kubectl get statefulset web -n storage -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    
    # Check replicas
    REPLICAS=$(kubectl get statefulset web -n storage -o jsonpath='{.spec.replicas}' 2>/dev/null)
    
    # Check service name
    SERVICE_NAME=$(kubectl get statefulset web -n storage -o jsonpath='{.spec.serviceName}' 2>/dev/null)
    
    if [[ "$IMAGE" == "nginx:stable" && "$REPLICAS" == "3" && "$SERVICE_NAME" == "web" ]]; then
        # All specifications are correct
        exit 0
    else
        echo "StatefulSet 'web' does not have correct specifications."
        echo "Found image: $IMAGE (expected: nginx:stable)"
        echo "Found replicas: $REPLICAS (expected: 3)"
        echo "Found service name: $SERVICE_NAME (expected: web)"
        exit 1
    fi
else
    # StatefulSet does not exist
    echo "StatefulSet 'web' does not exist in the 'storage' namespace"
    exit 1
fi 