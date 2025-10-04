#!/bin/bash

set -e

# Variables
NAMESPACE="production"
IMAGE_TAG=${1:-latest}
REGISTRY=${REGISTRY:-"ghcr.io"}
IMAGE_NAME=${IMAGE_NAME:-"hello-world-app"}
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "🚀 Deploying to production environment..."
echo "Image: ${FULL_IMAGE}"

# Create namespace if it doesn't exist
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Update image placeholder in deployment manifest
sed "s|PLACEHOLDER_IMAGE|${FULL_IMAGE}|g" k8s/production/deployment.yaml > /tmp/production-deployment.yaml

# Apply the deployment
kubectl apply -f /tmp/production-deployment.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/hello-world-production -n ${NAMESPACE} --timeout=600s

# Verify deployment health
echo "🔍 Verifying deployment health..."
kubectl get pods -n ${NAMESPACE} -l app=hello-world

# Run health check
EXTERNAL_IP=$(kubectl get service hello-world-production-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ ! -z "$EXTERNAL_IP" ]; then
    echo "🌐 Testing application health..."
    for i in {1..5}; do
        if curl -f http://${EXTERNAL_IP}; then
            echo "✅ Health check passed!"
            break
        else
            echo "⏳ Waiting for service to be ready... (attempt $i/5)"
            sleep 10
        fi
    done
fi

# Get service information
echo "📝 Deployment completed successfully!"
echo "Service information:"
kubectl get services -n ${NAMESPACE}

# Get ingress information
echo "Ingress information:"
kubectl get ingress -n ${NAMESPACE}

# Clean up temporary file
rm -f /tmp/production-deployment.yaml

echo "✅ Production deployment completed!"
echo "🌐 Application should be available at: https://hello-world.example.com"
