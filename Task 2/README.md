
# Multi-Cloud Kubernetes WordPress Deployment Guide

This guide provides step-by-step instructions for deploying WordPress on managed Kubernetes services across **Google Cloud (GKE)**, **Azure (AKS)**, and **AWS (EKS)** using **Helm** for simplified installation.

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
gcloud components install gke-gcloud-auth-plugin
kubectl version --client
```

> **Autopilot Mode Notes:**
> - Nodes are dynamically created only when pods are deployed.
> - `kubectl get nodes` will return empty until you deploy workloads.

### 3. Install Helm
```sh
brew install helm
```

### 4. Add and Update Bitnami Helm Repository
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 5. Deploy WordPress Using Helm
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

### 6. Get the WordPress URL
```sh
kubectl get svc --namespace wordpress -w my-wordpress
```

### 7. Delete the GKE Cluster
```sh
gcloud container clusters delete wordpress-cluster --region us-central1 --quiet
```

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

### 2. Add a User Node Pool with Free Tier Size (Standard_B1s)
```sh
az aks nodepool add \
  --resource-group wordpress-rg \
  --cluster-name wordpress-cluster \
  --name userpool \
  --node-count 1 \
  --node-vm-size Standard_B1s \
  --mode User
```

### 3. Scale Down the System Node Pool to Save Cost
```sh
az aks nodepool scale \
  --resource-group wordpress-rg \
  --cluster-name wordpress-cluster \
  --name nodepool1 \
  --node-count 0
```

> **Note on Free Tier Usage:**
> - Azure often restricts very small SKUs like `Standard_B1s` for AKS workloads.
> - If you see a message like:
>   *"The VM SKUs chosen for agentpool(s) `userpool` are restricted by AKS..."*  
>   Refer to the [AKS restricted SKUs list](https://aka.ms/aks/restricted-skus).

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

- [GKE Autopilot Documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
- [AKS Restricted SKUs](https://aka.ms/aks/restricted-skus)
- [Bitnami WordPress Helm Chart](https://bitnami.com/stack/wordpress/helm)
- [eksctl Documentation](https://eksctl.io/)

---
