#!/bin/bash

# cleanup-exam-env.sh
# 
# This script cleans up the exam environment on the jumphost.
# It removes all resources created during the exam to prepare for a new exam.
#
# Usage: cleanup-exam-env.sh
#
# Example: cleanup-exam-env.sh

# Log function with timestamp
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting exam environment cleanup"
log "Cleaning up cluster $CLUSTER_NAME"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null candidate@k8s-api-server "env-cleanup $CLUSTER_NAME"

#cleanup docker env
log "Cleaning up docker environment"
docker system prune -a --volumes -f
docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls -q)
docker container rm $(docker container ls -q)
docker image rm $(docker image ls -q)
docker volume rm $(docker volume ls -q)

# Remove the exam environment directory
log "Removing exam environment directory"
rm -rf /tmp/exam-env
rm -rf /tmp/exam

# Remove the exam assets directory
log "Removing exam assets directory"
rm -rf /tmp/exam-assets

log "Exam environment cleanup completed successfully"
exit 0 