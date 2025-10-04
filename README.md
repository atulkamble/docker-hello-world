# Docker Hello World

A simple Docker project that serves a static HTML website using nginx alpine image.

## Project Structure

```
docker-hello-world/
├── Dockerfile
├── html/
│   └── (HTML files)
└── README.md
```

## Prerequisites

- Docker installed on your system
- Basic knowledge of Docker commands
- Minikube (optional, for Kubernetes deployment)
- kubectl (optional, for Kubernetes management)

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