#!/bin/bash

# Validate that the web headless service exists
SERVICE=$(kubectl get service web -n storage -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$SERVICE" == "web" ]]; then
    # Service exists, now check if it's a headless service
    CLUSTER_IP=$(kubectl get service web -n storage -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    
    if [[ "$CLUSTER_IP" == "None" ]]; then
        # This is a headless service
        
        # Check selector to make sure it matches the StatefulSet
        SELECTOR=$(kubectl get service web -n storage -o jsonpath='{.spec.selector.app}' 2>/dev/null)
        
        if [[ "$SELECTOR" != "" ]]; then
            # Selector exists
            exit 0
        else
            echo "Headless service 'web' does not have a selector"
            exit 1
        fi
    else
        echo "Service 'web' is not a headless service. ClusterIP: $CLUSTER_IP"
        exit 1
    fi
else
    # Service does not exist
    echo "Service 'web' does not exist in the 'storage' namespace"
    exit 1
fi 