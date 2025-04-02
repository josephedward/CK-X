#!/bin/bash

# Validate that the data-processor job exists
JOB=$(kubectl get job data-processor -n jobs -o jsonpath='{.metadata.name}' 2>/dev/null)

if [[ "$JOB" == "data-processor" ]]; then
    # Job exists, now check the specs
    
    # Check image
    IMAGE=$(kubectl get job data-processor -n jobs -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
    
    # Check command
    COMMAND=$(kubectl get job data-processor -n jobs -o jsonpath='{.spec.template.spec.containers[0].command}' 2>/dev/null)
    
    if [[ "$IMAGE" == "busybox" && "$COMMAND" == *"for i in"* && "$COMMAND" == *"seq 1 5"* ]]; then
        # Job has correct image and command
        exit 0
    else
        echo "Job 'data-processor' does not have correct specifications."
        echo "Found image: $IMAGE (expected: busybox)"
        echo "Found command: $COMMAND (expected: command that loops from 1 to 5)"
        exit 1
    fi
else
    # Job does not exist
    echo "Job 'data-processor' does not exist in the 'jobs' namespace"
    exit 1
fi 