#!/bin/bash

set -e

# Variables
NAMESPACE="staging"
IMAGE_TAG=${1:-latest}
REGISTRY=${REGISTRY:-"ghcr.io"}
IMAGE_NAME=${IMAGE_NAME:-"hello-world-app"}
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "🚀 Deploying to staging environment..."
echo "Image: ${FULL_IMAGE}"

# Create namespace if it doesn't exist
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Update image placeholder in deployment manifest
sed "s|PLACEHOLDER_IMAGE|${FULL_IMAGE}|g" k8s/staging/deployment.yaml > /tmp/staging-deployment.yaml

# Apply the deployment
kubectl apply -f /tmp/staging-deployment.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/hello-world-staging -n ${NAMESPACE} --timeout=300s

# Get service information
echo "📝 Deployment completed successfully!"
echo "Service information:"
kubectl get services -n ${NAMESPACE}

# Get ingress information
echo "Ingress information:"
kubectl get ingress -n ${NAMESPACE}

# Check pod status
echo "Pod status:"
kubectl get pods -n ${NAMESPACE} -l app=hello-world

# Clean up temporary file
rm -f /tmp/staging-deployment.yaml

echo "✅ Staging deployment completed!"
