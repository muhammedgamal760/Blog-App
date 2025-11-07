# AWS EKS Deployment Guide

This guide provides step-by-step instructions for deploying the Blog Application to Amazon EKS.

## Prerequisites

- AWS CLI installed and configured
- kubectl installed
- eksctl installed
- Docker installed
- Helm installed (for Helm deployment option)
- AWS account with appropriate permissions

## Step 1: Create ECR Repositories

```bash
# Set your AWS region
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create ECR repositories
aws ecr create-repository --repository-name blog-backend --region $AWS_REGION
aws ecr create-repository --repository-name blog-frontend --region $AWS_REGION
```

## Step 2: Build and Push Docker Images

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build images
cd backend
docker build -t blog-backend:latest .
cd ../frontend
docker build -t blog-frontend:latest .
cd ..

# Tag images
docker tag blog-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/blog-backend:latest
docker tag blog-frontend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/blog-frontend:latest

# Push images
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/blog-backend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/blog-frontend:latest
```

## Step 3: Create EKS Cluster

```bash
# Create EKS cluster (this takes 15-20 minutes)
eksctl create cluster \
  --name blog-cluster \
  --region $AWS_REGION \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 4 \
  --managed

# Verify cluster is running
kubectl get nodes
```

## Step 4: Configure EBS CSI Driver (for MySQL storage)

```bash
# Create IAM OIDC provider
eksctl utils associate-iam-oidc-provider --cluster=blog-cluster --approve

# Install EBS CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
```

## Step 5: Deploy Application

### Option A: Using Raw Kubernetes Manifests

```bash
# Update image URLs in manifests
sed -i "s|blog-backend:latest|$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/blog-backend:latest|g" k8s/backend-deployment.yaml
sed -i "s|blog-frontend:latest|$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/blog-frontend:latest|g" k8s/frontend-deployment.yaml

# Update imagePullPolicy to Always
sed -i "s|imagePullPolicy: Never|imagePullPolicy: Always|g" k8s/backend-deployment.yaml
sed -i "s|imagePullPolicy: Never|imagePullPolicy: Always|g" k8s/frontend-deployment.yaml

# Apply manifests
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod --all --timeout=300s
```

### Option B: Using Helm

```bash
# Update values.yaml with your ECR URLs
cat > custom-values.yaml <<EOF
mysql:
  persistence:
    storageClass: "gp2"

backend:
  image:
    repository: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/blog-backend
    tag: "latest"
    pullPolicy: Always

frontend:
  image:
    repository: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/blog-frontend
    tag: "latest"
    pullPolicy: Always
EOF

# Install with Helm
helm install my-blog helm/blog-app -f custom-values.yaml
```

## Step 6: Access the Application

```bash
# Get the LoadBalancer URL
kubectl get service frontend

# Access the application
echo "Application URL: http://$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

## Step 7: Configure Domain (Optional)

If you have a domain, you can configure Route53:

```bash
# Get LoadBalancer DNS
LB_DNS=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Create Route53 record (replace with your hosted zone ID and domain)
aws route53 change-resource-record-sets --hosted-zone-id YOUR_ZONE_ID --change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "blog.yourdomain.com",
      "Type": "CNAME",
      "TTL": 300,
      "ResourceRecords": [{"Value": "'$LB_DNS'"}]
    }
  }]
}'
```

## Step 8: Enable SSL/TLS with AWS Certificate Manager (Optional)

```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=blog-cluster

# Create certificate in ACM
aws acm request-certificate \
  --domain-name blog.yourdomain.com \
  --validation-method DNS \
  --region $AWS_REGION

# Update frontend service to use ALB with SSL
kubectl annotate service frontend \
  service.beta.kubernetes.io/aws-load-balancer-type=nlb \
  service.beta.kubernetes.io/aws-load-balancer-ssl-cert=arn:aws:acm:region:account:certificate/xxx \
  service.beta.kubernetes.io/aws-load-balancer-backend-protocol=http \
  service.beta.kubernetes.io/aws-load-balancer-ssl-ports=443
```

## Monitoring and Logging

### View Logs

```bash
# View backend logs
kubectl logs -l app=backend -f

# View frontend logs
kubectl logs -l app=frontend -f

# View MySQL logs
kubectl logs -l app=mysql -f
```

### Check Pod Status

```bash
# Get all pods
kubectl get pods

# Describe a pod
kubectl describe pod <pod-name>

# Get events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Scaling

```bash
# Scale backend
kubectl scale deployment backend --replicas=3

# Scale frontend
kubectl scale deployment frontend --replicas=3

# Enable autoscaling
kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=10
kubectl autoscale deployment frontend --cpu-percent=70 --min=2 --max=10
```

## Backup MySQL Database

```bash
# Create backup job
kubectl run mysql-backup --image=mysql:8.0 --restart=Never -- \
  mysqldump -h mysql -u bloguser -pblogpassword blog_db > backup.sql

# Copy backup from pod
kubectl cp mysql-backup:/backup.sql ./backup.sql
```

## Cost Optimization

### Use Spot Instances

```bash
# Create spot instance node group
eksctl create nodegroup \
  --cluster=blog-cluster \
  --region=$AWS_REGION \
  --name=spot-workers \
  --node-type=t3.medium \
  --nodes=2 \
  --nodes-min=1 \
  --nodes-max=5 \
  --spot
```

### Right-size Resources

Update resource requests and limits in your deployments to match actual usage.

## Cleanup

```bash
# Delete Helm release (if using Helm)
helm uninstall my-blog

# Delete Kubernetes resources (if using manifests)
kubectl delete -f k8s/

# Delete EKS cluster
eksctl delete cluster --name blog-cluster --region $AWS_REGION

# Delete ECR repositories
aws ecr delete-repository --repository-name blog-backend --force --region $AWS_REGION
aws ecr delete-repository --repository-name blog-frontend --force --region $AWS_REGION
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check events
kubectl get events

# Check logs
kubectl logs <pod-name>
```

### LoadBalancer not getting external IP

```bash
# Check service
kubectl describe service frontend

# Verify AWS Load Balancer Controller is installed
kubectl get deployment -n kube-system aws-load-balancer-controller
```

### Database connection issues

```bash
# Test MySQL connectivity from backend pod
kubectl exec -it <backend-pod-name> -- sh
apk add mysql-client
mysql -h mysql -u bloguser -pblogpassword blog_db
```

## Production Best Practices

1. **Use Secrets Manager**: Store sensitive data in AWS Secrets Manager
2. **Enable Pod Security Policies**: Restrict pod capabilities
3. **Implement Network Policies**: Control traffic between pods
4. **Set up CloudWatch Logs**: Centralized logging
5. **Enable Container Insights**: Monitor cluster metrics
6. **Use Private Subnets**: Place worker nodes in private subnets
7. **Implement Backup Strategy**: Regular database backups
8. **Set Resource Limits**: Prevent resource exhaustion
9. **Use Multiple Availability Zones**: High availability
10. **Implement CI/CD**: Automated deployments

## Cost Estimate

Approximate monthly costs for running on EKS:

- EKS Control Plane: $73/month
- 2x t3.medium nodes: ~$60/month
- EBS volumes: ~$5/month
- Load Balancer: ~$20/month
- Data transfer: Variable

**Total: ~$160-200/month**

Use spot instances and right-sizing to reduce costs by 50-70%.
