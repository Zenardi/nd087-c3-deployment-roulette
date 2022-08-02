#!/bin/bash

# 1 / PERCENTAGE => 1 / 0.5 = 2 (1 / 50%)
DEPLOY_PERCENTAGE=2

function canary_deploy {
  NUM_OF_V1_PODS=$(kubectl get pods -n udacity | grep -c canary-v1)
  echo "V1 PODS: $NUM_OF_V1_PODS"
  NUM_OF_V2_PODS=$(kubectl get pods -n udacity | grep -c canary-v2)
  echo "V2 PODS: $NUM_OF_V2_PODS"

  REPLICAS=$((DEPLOY_PERCENTAGE * NUM_OF_V2_PODS))

  kubectl scale deployment canary-v2 --replicas=$REPLICAS
  kubectl scale deployment canary-v1 --replicas=$REPLICAS
  # Check deployment rollout status every 1 second until complete.
  ATTEMPTS=0
  ROLLOUT_STATUS_CMD="kubectl rollout status deployment/canary-v2 -n udacity"
  until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
    $ROLLOUT_STATUS_CMD
    ATTEMPTS=$((attempts + 1))
    sleep 1
  done
  echo "Canary deployment of 1 / $DEPLOY_PERCENTAGE percentage successful!"
}

# Initialize canary-v2 deployment
kubectl apply -f starter/apps/canary/canary-v2.yml

sleep 1
# Begin canary deployment
canary_deploy

echo "Canary deployment of v2 successful"