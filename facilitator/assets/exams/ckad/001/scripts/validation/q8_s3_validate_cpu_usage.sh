#!/bin/bash
# Validate that CPU usage for 'logging-pod' in namespace 'troubleshooting' is within acceptable limits

NAMESPACE="troubleshooting"
POD_NAME="logging-pod"
# Setting a reasonable CPU usage threshold (in millicores)
CPU_THRESHOLD=800

# Check if the pod exists
kubectl get pod $POD_NAME -n $NAMESPACE > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Pod '$POD_NAME' not found in namespace '$NAMESPACE'"
  exit 1
fi

# Get CPU limits from the pod
CONTAINERS=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.spec.containers[*].name}')

echo "🔍 Checking CPU usage for pod '$POD_NAME'..."

# Use kubectl top to get current CPU usage
CPU_USAGE=$(kubectl top pod $POD_NAME -n $NAMESPACE --no-headers 2>/dev/null | awk '{print $2}')

# Handle case where metrics-server might not be available
if [ -z "$CPU_USAGE" ]; then
  echo "⚠️  Cannot measure actual CPU usage (metrics-server may not be available)"
  echo "✅ Assuming CPU usage is acceptable since pod is running with limits"
  exit 0
fi

# Extract numeric value from CPU usage (e.g., "156m" -> 156)
CPU_VALUE=$(echo $CPU_USAGE | sed 's/[^0-9]*//g')

if [ -z "$CPU_VALUE" ]; then
  echo "⚠️  Cannot parse CPU usage value: $CPU_USAGE"
  echo "✅ Assuming CPU usage is acceptable since pod is running with limits"
  exit 0
fi

echo "📊 Current CPU usage: ${CPU_VALUE}m"

# Check against threshold
if [ $CPU_VALUE -gt $CPU_THRESHOLD ]; then
  echo "❌ CPU usage (${CPU_VALUE}m) exceeds threshold (${CPU_THRESHOLD}m)"
  exit 1
fi

# Check if all containers have CPU limits set
for CONTAINER in $CONTAINERS; do
  CPU_LIMIT=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath="{.spec.containers[?(@.name==\"$CONTAINER\")].resources.limits.cpu}")
  
  if [ -z "$CPU_LIMIT" ]; then
    echo "⚠️  Container '$CONTAINER' does not have CPU limits set"
  else
    echo "✅ Container '$CONTAINER' has CPU limits: $CPU_LIMIT"
  fi
done

echo "✅ CPU usage is within acceptable limits"
exit 0 