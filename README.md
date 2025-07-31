# Mario Game on AWS EKS

Deploy Super Mario game on Amazon EKS using Terraform.

## Prerequisites
- AWS CLI configured
- Terraform installed
- kubectl installed

## Deployment Steps

1. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform apply -auto-approve
   ```

2. **Deploy Application**
   ```bash
   ./deploy.sh
   ```

3. **Access Game**
   The script will output the LoadBalancer URL to access your Mario game.

## Files
- `main.tf` - EKS infrastructure
- `provider.tf` - AWS provider configuration
- `versions.tf` - Terraform version requirements
- `deployment.yaml` - Mario game Kubernetes deployment
- `service.yaml` - LoadBalancer service
- `deploy.sh` - Deployment script

## Cleanup
```bash
terraform destroy -auto-approve
```