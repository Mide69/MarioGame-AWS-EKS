#!/bin/bash

echo "Fixing node security group directly..."

# Get the node instance ID
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=private-dns-name,Values=$NODE_NAME" --query 'Reservations[0].Instances[0].InstanceId' --output text)

echo "Node: $NODE_NAME"
echo "Instance ID: $INSTANCE_ID"

# Get current security groups
CURRENT_SGS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId' --output text)
echo "Current security groups: $CURRENT_SGS"

# Add our new security group to the instance
NEW_SG="sg-00fd69834ebb59168"
ALL_SGS="$CURRENT_SGS $NEW_SG"

echo "Adding security group $NEW_SG to instance..."
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --groups $ALL_SGS

echo "Waiting 10 seconds for changes to take effect..."
sleep 10

echo "Testing connection..."
curl -I http://50.18.84.118:31451 || echo "Still not working - checking pod status"

echo "Pod status:"
kubectl get pods -o wide

echo "Testing pod directly:"
kubectl port-forward deployment/super-mario-app 8080:8080 &
PF_PID=$!
sleep 3
curl -I http://localhost:8080
kill $PF_PID