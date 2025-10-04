#!/bin/bash

# EKS Deployment Script for Docker Hello World

set -e

# Variables
CLUSTER_NAME="hello-world-cluster"
REGION="us-west-2"
NODE_GROUP_NAME="hello-world-nodes"
ECR_REPO_NAME="hello-world-app"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE_TAG="latest"
VPC_STACK_NAME="eks-vpc-stack"

echo "🚀 Starting EKS deployment..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
    echo "❌ eksctl is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Create ECR repository
echo "📦 Creating ECR repository..."
aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION || \
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $REGION

# Get ECR login token
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build and tag Docker image
echo "🏗️  Building Docker image..."
docker build -t $ECR_REPO_NAME:$IMAGE_TAG .
docker tag $ECR_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

# Push image to ECR
echo "⬆️  Pushing image to ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

# Create EKS cluster using eksctl (recommended)
echo "☸️  Creating EKS cluster with eksctl..."
eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --nodegroup-name $NODE_GROUP_NAME \
    --node-type t3.medium \
    --nodes 2 \
    --nodes-min 1 \
    --nodes-max 3 \
    --managed

# Basic EKS CLI Commands (alternative approach)
# To create EKS cluster using basic AWS CLI commands:
#
# 1. Create IAM service role for EKS:
# aws iam create-role --role-name eksServiceRole --assume-role-policy-document file://eks-service-role-trust-policy.json
# aws iam attach-role-policy --role-name eksServiceRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
#
# 2. Create VPC (use default VPC or create custom):
# aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text
#
# 3. Create EKS cluster:
# aws eks create-cluster --name $CLUSTER_NAME --version 1.28 --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/eksServiceRole --resources-vpc-config subnetIds=subnet-xxx,subnet-yyy
#
# 4. Wait for cluster to be active:
# aws eks wait cluster-active --name $CLUSTER_NAME --region $REGION
#
# 5. Create worker node IAM role:
# aws iam create-role --role-name NodeInstanceRole --assume-role-policy-document file://node-instance-role-trust-policy.json
# aws iam attach-role-policy --role-name NodeInstanceRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
# aws iam attach-role-policy --role-name NodeInstanceRole --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
# aws iam attach-role-policy --role-name NodeInstanceRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
#
# 6. Create managed node group:
# aws eks create-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_GROUP_NAME --subnets subnet-xxx subnet-yyy --node-role arn:aws:iam::$AWS_ACCOUNT_ID:role/NodeInstanceRole --instance-types t3.medium --scaling-config minSize=1,maxSize=3,desiredSize=2

# Update kubeconfig
echo "⚙️  Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Deploy application
echo "🚀 Deploying application..."
kubectl create deployment hello-world --image=$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG
kubectl expose deployment hello-world --type=LoadBalancer --port=80

# Wait for service to be ready
echo "⏳ Waiting for LoadBalancer to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/hello-world

# Get service URL
echo "🌐 Getting service URL..."
kubectl get services hello-world

echo "✅ EKS deployment completed!"
echo "📝 To access your application, use the EXTERNAL-IP from the service above"
echo ""
echo "🔧 Basic EKS CLI Commands:"
echo "  Create cluster: aws eks create-cluster --name CLUSTER_NAME --role-arn ROLE_ARN --resources-vpc-config subnetIds=SUBNET_IDS"
echo "  List clusters: aws eks list-clusters --region $REGION"
echo "  Describe cluster: aws eks describe-cluster --name $CLUSTER_NAME --region $REGION"
echo "  Update kubeconfig: aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME"
echo "  Delete cluster: aws eks delete-cluster --name $CLUSTER_NAME --region $REGION"
echo ""
echo "🧹 To clean up resources, run: eksctl delete cluster --name $CLUSTER_NAME --region $REGION"
