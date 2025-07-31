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

# Get node external IP and service port
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
SERVICE_PORT=$(kubectl get svc mario-service -o jsonpath='{.spec.ports[0].nodePort}')

echo "=================================="
echo "Mario Game deployed successfully!"
echo "Access your game at: http://$NODE_IP:$SERVICE_PORT"
echo "=================================="