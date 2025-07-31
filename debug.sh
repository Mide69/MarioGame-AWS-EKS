#!/bin/bash

echo "=== Debugging Load Balancer Issue ==="

echo "1. Checking pods status:"
kubectl get pods -o wide

echo -e "\n2. Checking service endpoints:"
kubectl get endpoints super-mario-service

echo -e "\n3. Checking service details:"
kubectl describe svc super-mario-service

echo -e "\n4. Testing pod directly:"
POD_NAME=$(kubectl get pods -l app=super-mario-app -o jsonpath='{.items[0].metadata.name}')
echo "Testing pod $POD_NAME directly:"
kubectl port-forward $POD_NAME 8080:8080 &
PF_PID=$!
sleep 3
curl -I http://localhost:8080 || echo "Pod not responding"
kill $PF_PID

echo -e "\n5. Checking node security groups:"
kubectl get nodes -o wide