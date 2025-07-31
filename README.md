# Mario Game on AWS EKS

Deploy Super Mario game on Amazon EKS using Terraform.

## Prerequisites
- AWS CLI configured
- Terraform installed
- kubectl installed

<img width="1919" height="1075" alt="Screenshot 2025-07-31 194747" src="https://github.com/user-attachments/assets/f96f666e-b1f9-4fbc-8683-e277ae0a8cfd" />  
<img width="1919" height="1026" alt="Screenshot 2025-07-31 180617" src="https://github.com/user-attachments/assets/47924462-9574-4388-af5f-d026b661f363" />
<img width="1919" height="1009" alt="Screenshot 2025-07-31 180538" src="https://github.com/user-attachments/assets/c3503c8f-83f2-44ba-9612-bcc9ddf94a7b" />


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
