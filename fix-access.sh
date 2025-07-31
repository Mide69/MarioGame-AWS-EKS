#!/bin/bash

echo "Installing AWS Load Balancer Controller..."

# Install cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

# Wait for cert-manager to be ready
echo "Waiting for cert-manager to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager

# Create service account
echo "Creating service account..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::061051215589:role/aws-load-balancer-controller
EOF

# Download and install AWS Load Balancer Controller
echo "Installing AWS Load Balancer Controller..."
curl -Lo v2_5_4_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.5.4/v2_5_4_full.yaml

# Remove the ServiceAccount section since we created it above
sed -i.bak -e '596,604d' ./v2_5_4_full.yaml

kubectl apply -f v2_5_4_full.yaml

# Patch the deployment with cluster name
kubectl patch deployment -n kube-system aws-load-balancer-controller \
  --type='merge' \
  -p='{"spec":{"template":{"spec":{"containers":[{"name":"controller","args":["--cluster-name=super-mario-cluster","--ingress-class=alb"]}]}}}}'

echo "Waiting for AWS Load Balancer Controller to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system

echo "Checking service status..."
kubectl get svc super-mario-service

echo "Done! Your app should be accessible at the EXTERNAL-IP shown above."