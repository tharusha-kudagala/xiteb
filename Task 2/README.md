# Step 1: Create AKS with system pool (B2s, minimum allowed)
az aks create \
  --resource-group wordpress-rg \
  --name wordpress-cluster \
  --node-count 1 \
  --node-vm-size Standard_B2s \
  --generate-ssh-keys

# Step 2: Add user node pool with smaller size (B1s - free tier)
az aks nodepool add \
  --resource-group wordpress-rg \
  --cluster-name wordpress-cluster \
  --name userpool \
  --node-count 1 \
  --node-vm-size Standard_B1s \
  --mode User

az aks nodepool scale \
  --resource-group wordpress-rg \
  --cluster-name wordpress-cluster \
  --name nodepool1 \
  --node-count 0

Message: The VM SKUs chosen for agentpool(s) `AgentPoolProfile:userpool` are restricted by AKS. This is typically due to small CPU/Memory. Please see https://aka.ms/aks/restricted-skus for more details.

GKE

gcloud container clusters create-auto wordpress-cluster \
  --region us-central1

gcloud components install kubectl
kubectl version --client
gcloud components install gke-gcloud-auth-plugin

In Autopilot mode:

Nodes do not exist until you deploy pods
GKE dynamically provisions nodes behind the scenes only when needed
You won’t see any kubectl get nodes output until workloads are running

brew install helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

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

  1. Get the WordPress URL by running these commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace wordpress -w my-wordpress'

gcloud container clusters delete wordpress-cluster --region us-central1 --quiet

EKS

eksctl create cluster \
  --name wordpress-cluster \
  --region us-east-1 \
  --nodes 1 \
  --node-type t2.micro \
  --nodes-min 1 \
  --nodes-max 1 \
  --with-oidc \
  --managed
