#!/bin/bash

# -------- Configuration --------
CLUSTER_NAME="springboot-cluster"
REGION="ca-central-1"
ECR_REPO_NAME="springboot-ecr"
NODEGROUP_NAME="linux-nodes"
NODE_TYPE="t3.medium"
K8S_VERSION="1.31"

# -------- Step 1: Create ECR Repo --------
echo "🔧 Creating ECR Repository..."
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $REGION 2>/dev/null

if [ $? -eq 0 ]; then
  echo "✅ ECR repository '$ECR_REPO_NAME' created successfully."
else
  echo "ℹ️ ECR repo may already exist or another issue occurred."
fi

# -------- Step 2: Create EKS Cluster --------
echo "🚀 Creating EKS Cluster and Managed Node Group..."
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --version $K8S_VERSION \
  --nodegroup-name $NODEGROUP_NAME \
  --node-type $NODE_TYPE \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

# -------- Step 3: Associate IAM OIDC Provider --------
echo "🔐 Associating IAM OIDC Provider..."
eksctl utils associate-iam-oidc-provider \
  --region $REGION \
  --cluster $CLUSTER_NAME \
  --approve

# -------- Step 4: Update kubeconfig --------
echo "📡 Updating kubeconfig..."
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

# -------- Step 5: Verify Setup --------
echo "✅ Verifying node status..."
kubectl get nodes

