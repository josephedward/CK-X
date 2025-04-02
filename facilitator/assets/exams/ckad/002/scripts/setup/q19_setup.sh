#!/bin/bash

# Delete the pod-networking namespace if it exists
echo "Setting up environment for Question 19 (Pod Networking)..."
kubectl delete namespace pod-networking --ignore-not-found=true

# Wait for deletion to complete
sleep 2

# Confirm environment is ready
echo "Environment ready for Question 19"
exit 0 