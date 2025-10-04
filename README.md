# Docker Hello World

A simple Docker project that serves a static HTML website using nginx alpine image.

## Project Structure

```
docker-hello-world/
├── Dockerfile
├── html/
│   └── (HTML files)
├── README.md
├── eks.sh
└── aks.sh
```

## Prerequisites

- Docker installed on your system
- Basic knowledge of Docker commands
- Minikube (optional, for Kubernetes deployment)
- kubectl (optional, for Kubernetes management)
- AWS CLI and eksctl (for EKS deployment)
- Azure CLI (for AKS deployment)

## Getting Started

### Docker Deployment

#### Build the Docker Image

```bash
docker build -t hello-world-app .
```

#### Run the Container (Development)

```bash
# Run in foreground with logs
docker run -p 8080:80 --name hello-world hello-world-app

# Run in background (detached mode)
docker run -d -p 8080:80 --name hello-world hello-world-app

# Run with custom port mapping
docker run -d -p 3000:80 --name hello-world hello-world-app
```

#### Access the Application

Open your web browser and navigate to:
```
http://localhost:8080
```

### Kubernetes/Minikube Deployment

#### Start Minikube

```bash
# Start minikube cluster
minikube start

# Enable ingress addon (optional)
minikube addons enable ingress

# Use minikube docker daemon
eval $(minikube docker-env)
```

#### Build Image in Minikube

```bash
# Build image in minikube's docker environment
docker build -t hello-world-app .
```

#### Deploy to Kubernetes

```bash
# Create deployment
kubectl create deployment hello-world --image=hello-world-app --port=80

# Set image pull policy to Never (for local images)
kubectl patch deployment hello-world -p '{"spec":{"template":{"spec":{"containers":[{"name":"hello-world-app","imagePullPolicy":"Never"}]}}}}'

# Expose the deployment
kubectl expose deployment hello-world --type=NodePort --port=80

# Get service URL
minikube service hello-world --url
```

#### Alternative: Using YAML manifests

Create deployment and service with kubectl apply:

```bash
# Create deployment.yaml and service.yaml files, then:
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

#### Kubernetes Management Commands

```bash
# View deployments
kubectl get deployments

# View pods
kubectl get pods

# View services
kubectl get services

# Scale deployment
kubectl scale deployment hello-world --replicas=3

# Delete deployment
kubectl delete deployment hello-world

# Delete service
kubectl delete service hello-world

# Stop minikube
minikube stop

# Delete minikube cluster
minikube delete
```

## Cloud Deployments

### Amazon EKS Deployment

#### Prerequisites for EKS
- AWS CLI installed and configured
- eksctl installed
- kubectl installed
- Docker installed
- Appropriate AWS permissions for EKS, ECR, and IAM

#### Deploy to EKS

```bash
# Make the script executable
chmod +x eks.sh

# Run the EKS deployment script
./eks.sh
```

The script will:
1. Create an ECR repository
2. Build and push the Docker image to ECR
3. Create an EKS cluster with managed node group
4. Deploy the application
5. Expose it via LoadBalancer service

#### Cleanup EKS Resources

```bash
# Delete the EKS cluster and all resources
eksctl delete cluster --name hello-world-cluster --region us-west-2

# Delete ECR repository
aws ecr delete-repository --repository-name hello-world-app --region us-west-2 --force
```

### Azure AKS Deployment

#### Prerequisites for AKS
- Azure CLI installed and configured
- kubectl installed
- Docker installed
- Appropriate Azure permissions for AKS, ACR, and resource groups

#### Deploy to AKS

```bash
# Make the script executable
chmod +x aks.sh

# Run the AKS deployment script
./aks.sh
```

The script will:
1. Create a resource group
2. Create an Azure Container Registry (ACR)
3. Build and push the Docker image to ACR
4. Create an AKS cluster
5. Deploy the application
6. Expose it via LoadBalancer service

#### Cleanup AKS Resources

```bash
# Delete the entire resource group (includes AKS cluster and ACR)
az group delete --name hello-world-rg --yes --no-wait
```

### Cloud Deployment Notes

- **EKS**: Uses AWS ECR for container registry and creates a LoadBalancer service
- **AKS**: Uses Azure Container Registry and creates a LoadBalancer service
- Both scripts include error handling and prerequisite checks
- Deployment typically takes 10-15 minutes for cluster creation
- Both scripts output the external IP address to access your application

## Docker Commands

### Stop the container
```bash
docker stop hello-world
```

### Remove the container
```bash
docker rm hello-world
```

### Remove the image
```bash
docker rmi hello-world-app
```

### View running containers
```bash
docker ps
```

## Features

- Lightweight nginx alpine base image
- Serves static HTML content
- Exposes port 80 inside container
- Maps to port 8080 on host machine
- Kubernetes/Minikube ready for container orchestration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the Docker build
5. Submit a pull request

## License

This project is open source and available under the MIT License.