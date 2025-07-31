@echo off
echo Configuring kubectl for EKS cluster...
aws eks update-kubeconfig --region us-west-1 --name super-mario-cluster

echo Installing AWS Load Balancer Controller...
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

timeout /t 30

echo Creating service account for AWS Load Balancer Controller...
kubectl apply -f - <<EOF
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

echo Installing AWS Load Balancer Controller...
kubectl apply -f https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.5.4/v2_5_4_full.yaml

echo Patching deployment...
kubectl patch deployment -n kube-system aws-load-balancer-controller --type='merge' -p='{"spec":{"template":{"spec":{"containers":[{"name":"controller","args":["--cluster-name=super-mario-cluster","--ingress-class=alb"]}]}}}}'

echo Waiting for load balancer controller to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system

echo Checking service status...
kubectl get svc super-mario-service

echo Done! Your app should be accessible at the EXTERNAL-IP shown above.