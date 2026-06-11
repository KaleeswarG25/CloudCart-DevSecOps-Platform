# CloudCart DevSecOps Platform

A production-grade, high-availability infrastructure topology engineered on Amazon Web Services (AWS). This architecture utilizes an automated GitOps continuous delivery engine, shift-left security orchestration, and a unified metrics-and-logs telemetry engine.

---

## 🏗️ System Architecture Overview

```text
┌──────────────┐      ┌─────────────────────────┐      ┌──────────────────────────┐
│  Developer   │ ───► │   GitHub Repository     │ ───► │  GitHub Actions Runner   │
│  Git Push    │      │  (Main Code Branch)     │      │  (CI Automation Engine)  │
└──────────────┘      └─────────────────────────┘      └──────────────────────────┘
                                                                   │
   ┌───────────────────────────────────────────────────────────────┤
   ▼                                                               ▼
┌─────────────────────────┐                                    ┌──────────────────────────┐
│ SonarQube Code Review   │                                    │ Aquasecurity Trivy Scan  │
│ (Static Analysis Gate)  │                                    │ (Container Image Safety) │
└─────────────────────────┘                                    └──────────────────────────┘
                                                                   │
                                                                   ▼
                                                       ┌──────────────────────────┐
                                                       │ Amazon ECR / DockerHub   │
                                                       │ (Secure Image Registry)  │
                                                       └──────────────────────────┘
                                                                   │
                                                                   ▼
                                                       ┌──────────────────────────┐
                                                       │ ArgoCD GitOps Controller │
                                                       │ (Monitors /gitops State) │
                                                       └──────────────────────────┘
                                                                   │
                                                                   ▼
                                                       ┌──────────────────────────┐
                                                       │   AWS EKS Cluster Core   │
                                                       └──────────────────────────┘
                                                                   │
                          ┌────────────────────────────────────────┴────────────────────────────────────────┐
                          ▼                                        ▼                                        ▼
             ┌─────────────────────────┐              ┌─────────────────────────┐              ┌─────────────────────────┐
             │    AWS ALB Ingress      │              │   Compute Node Groups   │              │   Private Data Tier     │
             │   (External Traffic)    │              │  (React & Node App Pods)│              │      (RDS MySQL)        │
             └─────────────────────────┘              └─────────────────────────┘              └─────────────────────────┘
                          │                                        │
                          └────────────────────────────────────────┬────────────────────────────────────────┘
                                                                   │
                                                                   ▼
                                                       ┌──────────────────────────┐
                                                       │   Prometheus & Loki      │
                                                       │ (Unified Telemetry Grid) │
                                                       └──────────────────────────┘
                                                                   │
                                                                   ▼
                                                       ┌──────────────────────────┐
                                                       │    Grafana Dashboards    │
                                                       │ (Real-Time System Logs)  │
                                                       └──────────────────────────┘
📂 Repository TopologyDirectory / FileFunctional Responsibility.github/workflows/Continuous Integration (CI) workflows executing automated testing, code quality, and asset compilation.app/frontend/Production-ready distribution source code for the client-facing dynamic user interface.terraform/Modular HashiCorp Infrastructure as Code (IaC) configuration scripts provisioning VPC, EKS, and RDS layouts.helm/Parameterized deployment charts defining resource sizing models, scaling rules, and software application charts.k8s/Standalone target-state platform manifest layers utilized for rapid cluster onboarding and local validations.gitops/Root tracking directory audited by the delivery controller for automated live infrastructure alignment.🛠️ Core Engineering Implementations1. Shift-Left Security PipelineEvery repository commit triggers an unalterable continuous integration workflow within GitHub Actions:Static Application Security Testing (SAST): Enforces code hygiene, design patterns verification, and early bug detection via SonarQube.Container Vulnerability Management: Scans compiled image layers and runtime software dependencies via Trivy to halt deployment configurations carrying known security vulnerabilities.Asset Optimization: Leverages multi-stage Docker configurations to remove build-time tooling, leaving minimal, production-secure Alpine assets.2. High-Availability Cloud TopologyManaged Orchestration: Utilizes AWS Elastic Kubernetes Service (EKS) across independent availability zones to guarantee platform fault tolerance.Network Isolation Engineering: Houses live containers and transactional data engines safely inside private subnets, exposing services through the AWS ALB Ingress Controller.3. Declarative GitOps AutomationState Synchronization: Leverages ArgoCD inside the cluster to align cluster state parameters dynamically with configurations in the gitops/ directory.Zero-Downtime Deployment Handling: Employs rolling update strategies to update underlying application containers without interrupting active traffic.4. Consolidated Telemetry StackMetric Engine: Monitors cluster hardware utilization and node allocations using Prometheus.Log Aggregator: Centralizes multi-tier container application log routing via Loki.Unified Dashboarding: Interconnects metric paths and log fields side-by-side inside customizable Grafana views.🚀 Deployment & Installation GuidePrerequisitesThe local execution workstation must have the following system binaries configured and authenticated:AWS CLI v2 (Configured via aws configure with administrative privileges)HashiCorp Terraform (v1.5.0+)Kubectl (Aligned with target cluster version)Helm v3Step 1: Provision Infrastructure with TerraformInitialize, validate, and apply the modular configuration stack to erect the AWS hosting footprint:Bashcd terraform
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
Step 2: Establish Secure Cluster Access AuthenticationUpdate your local terminal configuration context to securely interface with the target managed EKS control plane:Bashaws eks update-kubeconfig --region ap-south-1 --name CloudCart-Cluster

# Verify node registrations across availability zones
kubectl get nodes -o wide
Step 3: Install AWS Load Balancer Ingress ControllerDeploy the core cluster ingress management layer via Helm to allow automatic load balancer provisioning from your manifest specifications:Bashhelm repo add eks [https://aws.github.io/eks-charts](https://aws.github.io/eks-charts)
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=CloudCart-Cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller
Step 4: Configure ArgoCD Continuous Delivery EngineInstantiate the declarative GitOps operator workspace to govern automatic environment configuration reconciliation:Bashkubectl create namespace argocd
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)

# Await initialization of all component services
kubectl wait --namespace argocd --for=condition=ready pod --all --timeout=120s
Accessing the Administration ConsoleTo view the web-based tracking graph interface, fetch the credentials and proxy the cluster port:Bash# Retrieve and decode the administrative root password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Forward the service interface to your local loopback address
kubectl port-forward svc/argocd-server -n argocd 8080:443
Using an active web browser, navigate to https://localhost:8080, logging in with username admin and the unique password string generated above.Step 5: Install the Telemetry and Log StackDeploy the instrumentation components to analyze host hardware usage alongside system log fields:Bashhelm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm repo add grafana [https://grafana.github.io/helm-charts](https://grafana.github.io/helm-charts)
helm repo update

kubectl create namespace monitoring

# Install Prometheus metric servers and Grafana
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring

# Install Loki log aggregator with persistent storage allocations
helm install loki grafana/loki-stack -n monitoring --set loki.persistence.enabled=true,loki.persistence.size=10Gi
Connecting Log Aggregation to the Visualization DashboardMap local system access directly to the Grafana visualization layer:Bashkubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
Open a browser and point to http://localhost:3000. Authenticate into the administration dashboard.Select Connections ➔ Data Sources, click Add data source, and choose Loki.Configure the HTTP URL path to point directly to the cross-namespace endpoint:http://loki.monitoring.svc.cluster.local:3100Click Save & Test at the bottom to verify loop integrity.Step 6: Configure Pipeline Cryptographic SecretsTo enable automated updates, append the following target variables within the repository properties configuration (Settings ➔ Secrets and variables ➔ Actions):AWS_ACCESS_KEY_ID: Administrative automation key handle.AWS_SECRET_ACCESS_KEY: Administrative authorization password credential.SONAR_TOKEN: Unique code-scanner instance validation handle.DOCKERHUB_USERNAME: Core container storage warehouse access ID.DOCKERHUB_TOKEN: Secure container storage authorization secret token.Step 7: Bootstrap the Root Platform Target ApplicationApply the declarative application blueprint to let ArgoCD assume management over the component deployments:Bashkubectl apply -f gitops/application.yaml

# Verify tracking execution statuses from your workspace
kubectl get apps -n argocd
