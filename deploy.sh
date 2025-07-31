#!/bin/bash

# Deploy Mario Game to EKS
echo "Deploying Mario Game to EKS..."

# Update kubeconfig
aws eks update-kubeconfig --region us-west-1 --name super-mario-cluster

# Apply Kubernetes manifests
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Wait for deployment
kubectl wait --for=condition=available --timeout=300s deployment/super-mario-app

# Wait for LoadBalancer
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/super-mario-service --timeout=300s

# Get LoadBalancer URL
LB_URL=$(kubectl get svc super-mario-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "=================================="
echo "Mario Game deployed successfully!"
echo "Access your game at: http://$LB_URL"
echo "=================================="