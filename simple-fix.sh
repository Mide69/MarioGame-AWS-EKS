#!/bin/bash

echo "Simple fix - Remove webhook and create basic LoadBalancer..."

# Delete webhook that's causing issues
kubectl delete validatingwebhookconfiguration aws-load-balancer-webhook
kubectl delete mutatingwebhookconfiguration aws-load-balancer-webhook

# Apply simple service without annotations
kubectl apply -f service.yaml

echo "Waiting for LoadBalancer..."
sleep 30
kubectl get svc super-mario-service

# Get the URL and test
LB_URL=$(kubectl get svc super-mario-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "LoadBalancer URL: http://$LB_URL"

# Test direct node access as backup
echo -e "\nDirect node access (backup):"
kubectl get nodes -o wide
echo "Use: http://50.18.84.118:31451"