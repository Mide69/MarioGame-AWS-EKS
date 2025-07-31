#!/bin/bash

echo "=== COMPLETE DIAGNOSIS ==="

echo "1. Checking pods status and logs:"
kubectl get pods -o wide
kubectl logs -l app=super-mario-app --tail=10

echo -e "\n2. Testing pod directly:"
POD_NAME=$(kubectl get pods -l app=super-mario-app -o jsonpath='{.items[0].metadata.name}')
echo "Testing pod $POD_NAME on port 8080:"
kubectl exec $POD_NAME -- curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 || echo "Pod not responding"

echo -e "\n3. Checking service endpoints:"
kubectl get endpoints super-mario-service

echo -e "\n4. Current service configuration:"
kubectl get svc super-mario-service -o yaml

echo -e "\n5. Node security groups:"
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=private-dns-name,Values=$NODE_NAME" --query 'Reservations[0].Instances[0].InstanceId' --output text)
echo "Node Instance ID: $INSTANCE_ID"
aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId' --output text

echo -e "\n6. Testing node port directly from inside cluster:"
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl -m 10 http://$NODE_IP:31451