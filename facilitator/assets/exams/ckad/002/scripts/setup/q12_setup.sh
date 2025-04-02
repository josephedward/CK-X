#!/bin/bash

# Delete the storage namespace if it exists
echo "Setting up environment for Question 12 (StatefulSet)..."
kubectl delete namespace storage --ignore-not-found=true

# Wait for deletion to complete
sleep 2

# Confirm environment is ready
echo "Environment ready for Question 12"
exit 0 