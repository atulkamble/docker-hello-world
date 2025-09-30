# Docker Hello World - Nginx Static Site

A simple containerized static website using Nginx that demonstrates basic Docker concepts.

## 🚀 Features

- Lightweight Nginx Alpine image
- Simple HTML static site
- Docker Compose setup
- Kubernetes deployment ready
- Multi-platform Docker image

## 📁 Project Structure

```
docker-hello-world/
├── Dockerfile
├── html/index.html
├── docker-compose.yml
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
└── README.md
```

## 🛠️ Quick Start

### Using Docker Compose

```bash
# Clone the repository
git clone https://github.com/atulkamble/docker-hello-world.git
cd docker-hello-world

# Run with Docker Compose
docker compose up -d

# View the site
open http://localhost:80
```

### Using Docker directly

```bash
# Build the image
docker build -t atuljkamble/docker-hello-world:latest .

# Run the container
docker run -d -p 80:80 atuljkamble/docker-hello-world:latest
```

### Using Kubernetes

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/

# Check the service
kubectl get services

# Access via NodePort (if using local cluster)
# http://localhost:30080
```

## 🏗️ Build & Push to Docker Hub

```bash
# Build multi-platform image
docker buildx build --platform linux/amd64,linux/arm64 \
  -t atuljkamble/docker-hello-world:latest \
  -t atuljkamble/docker-hello-world:v1.0.0 \
  --push .
```

## 🧪 Testing

```bash
# Test the running container
curl http://localhost:80

# Expected response: HTML page with "Hello, Cloudnautic!"
```

## 🔧 Configuration

- **Port**: 80 (HTTP)
- **Base Image**: nginx:alpine
- **Content**: Static HTML files in `/html` directory

## 📦 Docker Image

- **Registry**: Docker Hub
- **Repository**: `atuljkamble/docker-hello-world`
- **Tags**: `latest`, `v1.0.0`

## 🚀 Deployment Options

### Local Development
```bash
docker compose up -d
```

### Production (Kubernetes)
```bash
kubectl apply -f k8s/
```

### Cloud Platforms
- AWS ECS/EKS
- Azure Container Instances/AKS
- Google Cloud Run/GKE

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🌟 Cloudnautic

Part of the Docker Build Projects Pack by Cloudnautic - Ready-to-deploy containerized applications.

---

**Author**: Atul Kamble  
**Docker Hub**: [atuljkamble/docker-hello-world](https://hub.docker.com/r/atuljkamble/docker-hello-world)  
**GitHub**: [atulkamble/docker-hello-world](https://github.com/atulkamble/docker-hello-world)