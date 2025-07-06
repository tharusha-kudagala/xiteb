# Multi-Cloud Kubernetes WordPress Deployment Guide

This guide provides step-by-step instructions for deploying WordPress on managed Kubernetes services across Azure (AKS), Google Cloud (GKE), and AWS (EKS). It also covers using Helm for easy WordPress installation.

---

## Azure Kubernetes Service (AKS)

### 1. Create AKS Cluster with System Pool (Standard_B2s)
```sh
az aks create \
  --resource-group wordpress-rg \
  --name wordpress-cluster \
  --node-count 1 \
  --node-vm-size Standard_B2s \
  --generate-ssh-keys
```

### 2. Add User Node Pool with Smaller Size (Standard_B1s - Free Tier)
```sh
az aks nodepool add \
  --resource-group wordpress-rg \
  --cluster-name wordpress-cluster \
  --name userpool \
  --node-count 1 \
  --node-vm-size Standard_B1s \
  --mode User
```

### 3. Scale Down the System Node Pool
```sh
az aks nodepool scale \
  --resource-group wordpress-rg \
  --cluster-name wordpress-cluster \
  --name nodepool1 \
  --node-count 0
```

> **Note:**
> You may encounter a message:
> *The VM SKUs chosen for agentpool(s) `AgentPoolProfile:userpool` are restricted by AKS. This is typically due to small CPU/Memory. Please see [AKS restricted SKUs](https://aka.ms/aks/restricted-skus) for more details.*

---

## Google Kubernetes Engine (GKE)

### 1. Create an Autopilot Cluster
```sh
gcloud container clusters create-auto wordpress-cluster \
  --region us-central1
```

### 2. Install Required Tools
```sh
gcloud components install kubectl
kubectl version --client
gcloud components install gke-gcloud-auth-plugin
```

> **Autopilot Mode Note:**
> - Nodes do not exist until you deploy pods.
> - GKE dynamically provisions nodes behind the scenes only when needed.
> - You won’t see any `kubectl get nodes` output until workloads are running.

---

## Helm Installation and WordPress Deployment

### 1. Install Helm
```sh
brew install helm
```

### 2. Add and Update Bitnami Helm Repository
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 3. Install WordPress with Helm
```sh
helm install my-wordpress bitnami/wordpress \
  --namespace wordpress --create-namespace \
  --set wordpressUsername=admin \
  --set wordpressPassword=admin123 \
  --set mariadb.auth.rootPassword=root123 \
  --set service.type=LoadBalancer \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=256Mi \
  --set mariadb.primary.resources.requests.cpu=100m \
  --set mariadb.primary.resources.requests.memory=256Mi
```

#### Get the WordPress URL
> It may take a few minutes for the LoadBalancer IP to be available.  
> Watch the status with:
```sh
kubectl get svc --namespace wordpress -w my-wordpress
```

### 4. Delete the GKE Cluster
```sh
gcloud container clusters delete wordpress-cluster --region us-central1 --quiet
```

---

## Amazon Elastic Kubernetes Service (EKS)

### 1. Create EKS Cluster with eksctl
```sh
eksctl create cluster \
  --name wordpress-cluster \
  --region us-east-1 \
  --nodes 1 \
  --node-type t2.micro \
  --nodes-min 1 \
  --nodes-max 1 \
  --with-oidc \
  --managed
```

---

## References

- [AKS Restricted SKUs](https://aka.ms/aks/restricted-skus)
- [Bitnami WordPress Helm Chart](https://bitnami.com/stack/wordpress/helm)
- [GKE Autopilot Documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
- [eksctl Documentation](https://eksctl.io/)

---

**Feel free to adapt these steps for your specific cloud provider and environment.**
