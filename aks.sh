#!/bin/bash

# AKS Deployment Script for Docker Hello World

set -e

# Variables
RESOURCE_GROUP="hello-world-rg"
CLUSTER_NAME="hello-world-cluster"
ACR_NAME="helloworldacr$(date +%s)"
LOCATION="eastus"
IMAGE_TAG="latest"

echo "🚀 Starting AKS deployment..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Login to Azure (if not already logged in)
echo "🔐 Checking Azure login..."
az account show &> /dev/null || az login

# Create resource group
echo "📦 Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Container Registry
echo "🗃️  Creating Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic

# Login to ACR
echo "🔐 Logging into ACR..."
az acr login --name $ACR_NAME

# Build and push image to ACR
echo "🏗️  Building and pushing image to ACR..."
az acr build --registry $ACR_NAME --image hello-world-app:$IMAGE_TAG .

# Create AKS cluster (basic command)
echo "☸️  Creating AKS cluster..."
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 2 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --attach-acr $ACR_NAME

# Basic AKS CLI Commands (alternative approach)
# To create AKS cluster using basic Azure CLI commands:
#
# 1. Create resource group:
# az group create --name myResourceGroup --location eastus
#
# 2. Create AKS cluster (minimal):
# az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
#
# 3. Create AKS cluster (with specific options):
# az aks create \
#   --resource-group myResourceGroup \
#   --name myAKSCluster \
#   --node-count 2 \
#   --vm-set-type VirtualMachineScaleSets \
#   --load-balancer-sku standard \
#   --enable-cluster-autoscaler \
#   --min-count 1 \
#   --max-count 3 \
#   --generate-ssh-keys
#
# 4. Get credentials:
# az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
#
# 5. Create ACR and attach to AKS:
# az acr create --resource-group myResourceGroup --name myACR --sku Basic
# az aks update --name myAKSCluster --resource-group myResourceGroup --attach-acr myACR

# Get AKS credentials
echo "⚙️  Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Deploy application
echo "🚀 Deploying application..."
kubectl create deployment hello-world --image=$ACR_NAME.azurecr.io/hello-world-app:$IMAGE_TAG
kubectl expose deployment hello-world --type=LoadBalancer --port=80

# Wait for service to be ready
echo "⏳ Waiting for LoadBalancer to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/hello-world

# Get service URL
echo "🌐 Getting service URL..."
kubectl get services hello-world

echo "✅ AKS deployment completed!"
echo "📝 To access your application, use the EXTERNAL-IP from the service above"
echo ""
echo "🔧 Basic AKS CLI Commands:"
echo "  Create cluster: az aks create --resource-group RG_NAME --name CLUSTER_NAME --node-count 2 --generate-ssh-keys"
echo "  List clusters: az aks list --output table"
echo "  Show cluster: az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME"
echo "  Get credentials: az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME"
echo "  Scale cluster: az aks scale --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --node-count 3"
echo "  Delete cluster: az aks delete --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME"
echo ""
echo "🧹 To clean up resources, run: az group delete --name $RESOURCE_GROUP --yes --no-wait"
