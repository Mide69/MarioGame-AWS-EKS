#!/bin/bash

# Deploy Mario Game to EKS
echo "Deploying Mario Game to EKS..."

# Get cluster name from terraform output
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION="us-west-1"

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/super-mario-app

# Get service URL
echo "Getting service URL..."
kubectl get svc super-mario-service

echo "Deployment complete! Check the LoadBalancer URL above to access your Mario game."