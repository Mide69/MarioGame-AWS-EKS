#!/bin/bash

echo "Fixing AWS Load Balancer Controller..."

# Delete existing broken controller
kubectl delete deployment aws-load-balancer-controller -n kube-system

# Install using Helm (proper way)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add EKS repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=super-mario-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# Apply LoadBalancer service
kubectl apply -f service.yaml

echo "Waiting for LoadBalancer to be ready..."
sleep 30
kubectl get svc super-mario-service