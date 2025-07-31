#!/bin/bash

echo "Fixing security group for load balancer access..."

# Get the security group ID of the EKS cluster
CLUSTER_SG=$(aws eks describe-cluster --name super-mario-cluster --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text)
echo "Cluster Security Group: $CLUSTER_SG"

# Add rule to allow HTTP traffic from load balancer
aws ec2 authorize-security-group-ingress \
    --group-id $CLUSTER_SG \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Add rule for NodePort range
aws ec2 authorize-security-group-ingress \
    --group-id $CLUSTER_SG \
    --protocol tcp \
    --port 30000-32767 \
    --cidr 0.0.0.0/0

echo "Security group rules added. Testing load balancer..."
sleep 10
curl -I http://ab43fb49fc4db49f985420f57ff53082-1969306562.us-west-1.elb.amazonaws.com