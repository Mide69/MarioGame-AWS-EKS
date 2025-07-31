#!/bin/bash

echo "=== FINAL WORKING FIX ==="

# 1. Delete current broken deployment
kubectl delete deployment super-mario-app
kubectl delete service super-mario-service

# 2. Add security group rule to existing cluster security group
aws ec2 authorize-security-group-ingress \
    --group-id sg-0c7460210ee0f9652 \
    --protocol tcp \
    --port 31451 \
    --cidr 0.0.0.0/0 2>/dev/null || echo "Rule may already exist"

# 3. Deploy working Mario game
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mario-game
  labels:
    app: mario-game
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mario-game
  template:
    metadata:
      labels:
        app: mario-game
    spec:
      containers:
      - name: mario-game
        image: docker.io/pengbai/docker-supermario:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "256Mi"
            cpu: "250m"
          requests:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: mario-service
spec:
  type: NodePort
  selector:
    app: mario-game
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 31451
EOF

# 4. Wait for deployment
echo "Waiting for deployment..."
kubectl wait --for=condition=available --timeout=300s deployment/mario-game

# 5. Test the working app
echo "Testing Mario game..."
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
echo "=== MARIO GAME READY ==="
echo "URL: http://$NODE_IP:31451"
curl -I http://$NODE_IP:31451 || echo "Testing from browser: http://$NODE_IP:31451"