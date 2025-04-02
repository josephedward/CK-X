#!/bin/bash

# Validate that the StatefulSet has a volume claim template
VCT=$(kubectl get statefulset web -n storage -o jsonpath='{.spec.volumeClaimTemplates[0].metadata.name}' 2>/dev/null)

if [[ "$VCT" != "" ]]; then
    # Volume claim template exists, check storage class and size
    
    # Check storage class
    STORAGE_CLASS=$(kubectl get statefulset web -n storage -o jsonpath='{.spec.volumeClaimTemplates[0].spec.storageClassName}' 2>/dev/null)
    
    # Check storage size
    STORAGE_SIZE=$(kubectl get statefulset web -n storage -o jsonpath='{.spec.volumeClaimTemplates[0].spec.resources.requests.storage}' 2>/dev/null)
    
    # Check mount path
    MOUNT_PATH=$(kubectl get statefulset web -n storage -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[0].mountPath}' 2>/dev/null)
    
    if [[ "$STORAGE_CLASS" == "standard" && "$STORAGE_SIZE" == "1Gi" && "$MOUNT_PATH" == "/usr/share/nginx/html" ]]; then
        # Volume claim template is configured correctly
        exit 0
    else
        echo "Volume claim template is not configured correctly."
        echo "Found storage class: $STORAGE_CLASS (expected: standard)"
        echo "Found storage size: $STORAGE_SIZE (expected: 1Gi)"
        echo "Found mount path: $MOUNT_PATH (expected: /usr/share/nginx/html)"
        exit 1
    fi
else
    # No volume claim template
    echo "StatefulSet 'web' does not have a volume claim template"
    exit 1
fi 