#!/bin/bash

echo "Final fix - Delete and recreate service with proper health check..."

# Delete current service
kubectl delete svc super-mario-service

# Create new service with health check path
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: super-mario-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "classic"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: "/"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "8080"
spec:
  type: LoadBalancer
  selector:
    app: super-mario-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOF

echo "Waiting for new LoadBalancer..."
sleep 30
kubectl get svc super-mario-service

echo "Testing new LoadBalancer URL..."
LB_URL=$(kubectl get svc super-mario-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "New URL: http://$LB_URL"
curl -I http://$LB_URL