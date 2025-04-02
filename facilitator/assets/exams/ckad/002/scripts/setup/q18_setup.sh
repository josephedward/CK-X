#!/bin/bash

# Delete the pod-scheduling namespace if it exists
echo "Setting up environment for Question 18 (Pod Scheduling)..."
kubectl delete namespace pod-scheduling --ignore-not-found=true

# Delete the high-priority PriorityClass if it exists
kubectl delete priorityclass high-priority --ignore-not-found=true

# Wait for deletion to complete
sleep 2

# Confirm environment is ready
echo "Environment ready for Question 18"
exit 0 