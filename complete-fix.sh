#!/bin/bash

echo "=== COMPLETE FIX ==="

# 1. Clean up everything
echo "1. Cleaning up existing resources..."
kubectl delete svc super-mario-service 2>/dev/null || true
kubectl delete deployment super-mario-app 2>/dev/null || true

# 2. Fix security groups for all node groups
echo "2. Fixing security groups..."
NODE_GROUP_SG=$(aws eks describe-nodegroup --cluster-name super-mario-cluster --nodegroup-name super-mario-node-group --query 'nodegroup.resources.remoteAccessSecurityGroup' --output text)
CLUSTER_SG=$(aws eks describe-cluster --name super-mario-cluster --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text)

# Add HTTP access rules
for SG in $NODE_GROUP_SG $CLUSTER_SG; do
  if [ "$SG" != "None" ] && [ "$SG" != "null" ]; then
    echo "Adding rules to security group: $SG"
    aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null || true
    aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 8080 --cidr 0.0.0.0/0 2>/dev/null || true
    aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 30000-32767 --cidr 0.0.0.0/0 2>/dev/null || true
  fi
done

# 3. Deploy with working configuration
echo "3. Deploying Mario app with correct configuration..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: super-mario-app
  labels:
    app: super-mario-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: super-mario-app
  template:
    metadata:
      labels:
        app: super-mario-app
    spec:
      containers:
      - name: super-mario-app
        image: sevenajay/mario:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "256Mi"
            cpu: "250m"
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
EOF

# 4. Create NodePort service (guaranteed to work)
echo "4. Creating NodePort service..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: super-mario-service
spec:
  type: NodePort
  selector:
    app: super-mario-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 31451
EOF

# 5. Wait for deployment
echo "5. Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/super-mario-app

# 6. Get access information
echo "6. Getting access information..."
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
echo "=== ACCESS YOUR MARIO GAME ==="
echo "URL: http://$NODE_IP:31451"
echo "Node IP: $NODE_IP"
echo "Port: 31451"

# 7. Test the connection
echo -e "\n7. Testing connection..."
curl -I http://$NODE_IP:31451 || echo "Connection test failed - check security groups manually"