// create aks cluster 

1. open terminal/powershell 

az login 
// select subscription 

2. paste following command 

// mac/linux

```
az aks create \
--resource-group DevOps \
--name mycluster \
--node-count 1 \
--enable-addons monitoring \
--generate-ssh-keys 
```

// on windows 

```
az aks create --resource-group DevOps --name mycluster --node-count 1 --enable-addons monitoring --generate-ssh-keys 
```
// run docker desktop in background for image building 

```
git clone https://github.com/atulkamble/docker-hello-world.git
cd /docker-hello-world

sudo docker build -t atuljkamble/docker-hello-world .
sudo docker images 

sudo docker login 
sudo docker push atuljkamble/docker-hello-world

cd k8s 

kubectl apply -f eks-deployment.yaml
kubectl apply -f eks-service.yaml
kubectl get nodes
kubectl get deployments 
kubectl get pods 
kubectl get services
kubectl get service hello-web-svc

// copy external ip and paste in browser 

```
