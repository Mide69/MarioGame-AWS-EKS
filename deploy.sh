#!/bin/bash

# Deploy Mario Game to EKS
echo "Deploying Mario Game to EKS..."

# Get cluster name and region
CLUSTER_NAME="super-mario-cluster"
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
kubectl wait --for=condition=available --timeout=300s deployment/mario-game

# Wait for LoadBalancer to get external IP
echo "Waiting for LoadBalancer to get external IP..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/mario-service --timeout=300s

# Get LoadBalancer URL
LB_URL=$(kubectl get svc mario-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "=================================="
echo "Mario Game deployed successfully!"
echo "Access your game at: http://$LB_URL"
echo "=================================="