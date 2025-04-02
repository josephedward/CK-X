#!/bin/bash

# Delete the resource-management namespace if it exists
echo "Setting up environment for Question 15 (Resource Quotas)..."
kubectl delete namespace resource-management --ignore-not-found=true

# Wait for deletion to complete
sleep 2

# Confirm environment is ready
echo "Environment ready for Question 15"
exit 0 