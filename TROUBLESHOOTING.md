# CloudCart DevSecOps - Troubleshooting Guide

## ALB Controller Metadata Access Issue

### Problem Summary
AWS Load Balancer Controller pods are in CrashLoopBackOff state with error:
```
failed to get VPC ID: failed to fetch VPC ID from instance metadata: 
error in fetching vpc id through ec2 metadata: 
get mac metadata: operation error ec2imds: GetMetadata, canceled, context deadline exceeded
```

### Root Cause Analysis

The controller attempts to reach EC2 Instance Metadata Service (IMDS) at `169.254.169.254:80` but requests timeout.

**Possible Causes:**
1. EKS node security group doesn't allow egress to 169.254.169.254
2. EC2 instances don't have required IAM instance profile
3. IMDSv2 misconfiguration (if enabled without proper token handling)
4. VPC network ACLs blocking the metadata endpoint
5. Pod networking issue (CNI misconfiguration)

### Diagnostic Steps

#### Step 1: Check Node Security Group
```bash
# Get EKS node security group
aws ec2 describe-instances \
  --instance-ids i-xxxxxxxx \
  --region ap-south-1 \
  --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId'

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids sg-xxxxxxxx \
  --region ap-south-1 \
  --query 'SecurityGroups[0].IpPermissions[*].[FromPort,ToPort,IpProtocol,IpRanges[0].CidrIp]'
```

**Fix: Add egress rule to metadata endpoint**
```bash
aws ec2 authorize-security-group-egress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 80 \
  --cidr 169.254.169.254/32 \
  --region ap-south-1
```

#### Step 2: Check Node IAM Role
```bash
# Get EC2 instance IAM role
aws ec2 describe-instances \
  --instance-ids i-xxxxxxxx \
  --region ap-south-1 \
  --query 'Reservations[0].Instances[0].IamInstanceProfile'

# Check role permissions
aws iam get-role --role-name eksctl-cloudcart-default-NodeInstanceRole
```

#### Step 3: Test Metadata Access from Pod
```bash
# Create a debug pod
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- sh

# Inside the pod, try:
curl -v http://169.254.169.254/latest/meta-data/mac
curl -v http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

#### Step 4: Check Pod Network
```bash
# Describe ALB controller pod
kubectl describe pod -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller

# Check pod logs
kubectl logs -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller \
  --all-containers=true
```

#### Step 5: Verify IRSA Configuration
```bash
# Check service account
kubectl get sa -n kube-system aws-load-balancer-controller -o yaml

# Verify role ARN is present:
# eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/ROLENAME

# Check role trust relationship
aws iam get-role \
  --role-name eksctl-cloudcart-default-addon-iamserviceacco-Role1-WfYJBuECqy9S \
  --query 'Role.AssumeRolePolicyDocument'
```

### Solution Options

#### Option 1: Fix Security Group Rules (Recommended)
1. Identify EKS node security group ID
2. Add egress rule to allow 169.254.169.254:80
3. Restart ALB controller pods

#### Option 2: Verify EC2 Instance Profile
1. Ensure all nodes have proper IAM instance profile
2. Instance profile must have EKS worker node policy
3. Restart ALB controller pods

#### Option 3: Reinstall with Different Configuration
```bash
# Uninstall current ALB controller
helm uninstall aws-load-balancer-controller -n kube-system

# Remove webhooks
kubectl delete validatingwebhookconfigurations \
  -l app.kubernetes.io/name=aws-load-balancer-controller

# Reinstall with explicit environment variables
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=cloudcart-default \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set env.AWS_EC2_ENDPOINT=https://ec2.ap-south-1.amazonaws.com \
  --set enableShield=false \
  --set enableWaf=false \
  --set logLevel=debug
```

#### Option 4: Workaround Without ALB
If ALB cannot be fixed immediately:
```bash
# Use NodePort service (already configured)
kubectl port-forward svc/cloudcart-frontend 8080:80 &

# Or use Service type LoadBalancer (creates NLB instead of ALB)
kubectl patch svc cloudcart-frontend -p '{"spec": {"type": "LoadBalancer"}}'
```

### Verification

Once fixed, verify ALB controller is working:
```bash
# Check controller pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Should show: Running, Ready 1/1

# Check webhook services
kubectl get svc -n kube-system | grep aws-load-balancer-webhook

# Deploy ingress
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  ingressClassName: alb
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cloudcart-frontend
            port:
              number: 80
EOF

# Check ingress status
kubectl get ingress test-ingress
# Should show ADDRESS with ALB DNS name
```

---

## Resource Constraints Issue

### Problem
Several pods are in Pending state due to insufficient resources:
- ArgoCD server, application-controller, repo-server
- Prometheus stack pods
- SonarQube pod
- Loki pod

### Solution: Scale Cluster

#### Option 1: Add More Nodes to Existing Node Group
```bash
# Get current node group
eksctl get nodegroup --cluster cloudcart-default --region ap-south-1

# Scale to 3 nodes
eksctl scale nodegroup \
  --cluster cloudcart-default \
  --name <NODEGROUP_NAME> \
  --nodes 3 \
  --region ap-south-1
```

#### Option 2: Increase Node Instance Type
```bash
# Get current instance type
eksctl get nodegroup --cluster cloudcart-default --region ap-south-1 -o json

# Delete and recreate with larger instance type
eksctl delete nodegroup \
  --cluster cloudcart-default \
  --name <NODEGROUP_NAME> \
  --region ap-south-1

eksctl create nodegroup \
  --cluster cloudcart-default \
  --name upgraded-nodegroup \
  --node-type t3.xlarge \
  --nodes 2 \
  --region ap-south-1
```

#### Option 3: Disable Non-Critical Components
```bash
# Reduce replica count of non-essential services
kubectl scale deployment argocd-dex-server -n argocd --replicas=0
kubectl scale deployment argocd-repo-server -n argocd --replicas=1
```

---

## ArgoCD Dex Server Crash

### Problem
`argocd-dex-server` pod keeps crashing with exit code 1

### Possible Causes
1. Missing OIDC provider configuration
2. TLS certificate issues
3. RBAC or service account permission issues
4. Configuration file issues

### Diagnostic Steps
```bash
# Check logs
kubectl logs -n argocd -c dex argocd-dex-server-xxxxxx

# Check configuration
kubectl get cm -n argocd dex-server -o yaml

# Check service account
kubectl get sa -n argocd argocd-dex-server

# Check role bindings
kubectl get rolebinding -n argocd | grep dex
```

### Solution
```bash
# Option 1: Disable Dex (if not using OAuth)
kubectl patch cm argocd-cm -n argocd -p '{"data":{"dex.config":""}}'

# Restart dex-server
kubectl rollout restart deployment/argocd-dex-server -n argocd

# Option 2: Reinstall ArgoCD without Dex
helm install argocd argo-cd/argo-cd \
  -n argocd \
  --set dex.enabled=false
```

---

## GitHub Actions Secrets Configuration

### Required Secrets for Complete CI/CD

```bash
# In GitHub repository settings -> Secrets and variables -> Actions

# 1. Docker Hub (existing)
DOCKERHUB_USERNAME=eswar2506
DOCKERHUB_TOKEN=<your-docker-hub-token>

# 2. SonarQube (needs configuration)
SONAR_HOST_URL=http://sonarqube.example.com:9000
SONAR_TOKEN=<generate-from-sonarqube>

# 3. ArgoCD (needs configuration)
ARGOCD_SERVER=argocd.example.com
ARGOCD_TOKEN=<generate-from-argocd>

# 4. AWS (if using in pipeline)
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>
AWS_REGION=ap-south-1
```

### Generate SonarQube Token
```bash
# 1. Port forward to SonarQube
kubectl port-forward svc/sonarqube-sonarqube -n sonarqube 9000:9000

# 2. Login at http://localhost:9000
#    Default: admin / admin123

# 3. Go to: My Account -> Security -> Generate Token
# 4. Copy token to SONAR_TOKEN secret
```

### Generate ArgoCD Token
```bash
# Get admin password
kubectl get secret -n argocd argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8081:443

# Login at https://localhost:8081
# Create new application token:
# Settings -> Accounts -> Create token
```

---

## Performance Tuning

### Optimize Resource Requests/Limits
```bash
# Check current resource usage
kubectl top pods --all-namespaces

# Adjust HPA settings
kubectl patch hpa cloudcart-frontend -p \
  '{"spec":{"targetCPUUtilizationPercentage":75}}'

# Increase max replicas
kubectl patch hpa cloudcart-frontend -p \
  '{"spec":{"maxReplicas":20}}'
```

### Monitor Memory Usage
```bash
# Watch memory usage
watch kubectl top nodes

# If consistently high, add more nodes
# If low, consider reducing resource requests
```

---

## Rollback Procedures

### Rollback Helm Release
```bash
# View release history
helm history cloudcart

# Rollback to previous version
helm rollback cloudcart
```

### Revert ArgoCD Application
```bash
# Sync to previous commit
argocd app sync cloudcart-app --revision <commit-hash>

# Or use Git to revert commit
git revert <commit-hash>
git push origin main
# ArgoCD will auto-sync to new state
```

---

## Common Commands

```bash
# Monitor deployments
kubectl rollout status deployment/cloudcart-frontend

# Scale application
kubectl scale deployment cloudcart-frontend --replicas=5

# View logs
kubectl logs -f deployment/cloudcart-frontend

# Shell into pod
kubectl exec -it <pod-name> -- /bin/sh

# Port forward service
kubectl port-forward svc/cloudcart-frontend 8080:80

# Describe resources
kubectl describe nodes
kubectl describe pod <pod-name>
kubectl describe pvc <pvc-name>

# Delete and recreate
kubectl delete pod <pod-name>  # Will be recreated by deployment

# Check events
kubectl get events --all-namespaces
```

---

## Support Resources

- **AWS EKS Documentation**: https://docs.aws.amazon.com/eks/
- **ALB Controller Issues**: https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues
- **ArgoCD Troubleshooting**: https://argo-cd.readthedocs.io/en/stable/faq/
- **Kubernetes Docs**: https://kubernetes.io/docs/
- **eksctl Documentation**: https://eksctl.io/

