# 🚀 The Platform Engineering Blueprint: Designing a Cloud-Native IDP

> 🏗️ **Architectural Vision in Progress** | *This repository serves as a conceptual blueprint and roadmap. The features described below outline the target architecture that is currently being built.*

This repository is an ongoing project aimed at building a professional **Internal Developer Platform (IDP)**. The ultimate vision is to deliver a production-ready environment secured with fine-grained RBAC, automated scaling, eBPF-powered network isolation, and a robust DevSecOps pipeline.

---

## 📖 Table of Contents
1. [📦 Internal Developer Platform (Backstage & Port)](#-internal-developer-platform-backstage--port)
2. [🔄 GitOps & Continuous Delivery (ArgoCD)](#-gitops--continuous-delivery-argocd)
3. [🛡️ DevSecOps & Security (CI/CD)](#-devsecops--security-cicd)
4. [🏗️ Infrastructure as Code (Terraform & LocalStack)](#-infrastructure-as-code-terraform--localstack)
5. [🌐 Networking & Observability (Cilium & Hubble)](#-networking--observability-cilium--hubble)
6. [📊 Monitoring & Metrics (Prometheus & Grafana)](#-monitoring--metrics-prometheus--grafana)
7. [🗄️ Storage & Databases (Redis & PostgreSQL)](#-storage--databases-redis--postgresql)
8. [🔑 Secrets Management (Sealed Secrets)](#-secrets-management-sealed-secrets)
9. [🚀 Apps & Base Implementation](#-apps--base-implementation)
10. [🚦 Local Access & Requirements](#-local-access--requirements)
11. [🛠️ Troubleshooting](#-troubleshooting)
12. [📂 Repository Structure](#-repository-structure)
13. [🤝 Contributing](#-contributing)
14. [🔮 Future Improvements](#-future-improvements)

---

## 📦 Internal Developer Platform (Backstage & Port)
* **Backstage.io:** Centralized portal for infrastructure and service management.
* **Port Integration:** Advanced software catalog and scorecard system.
* **Self-Service Actions:** Features a `Fix Port Scorecard` workflow, allowing developers to automate documentation updates directly from the Port UI.

## 🔄 GitOps & Continuous Delivery (ArgoCD)
* **App-of-Apps Pattern:** A **Root-App** (found in `/bootstrap`) recursively manages all platform components within the `/infrastructure` directory.
* **Component-Based Delivery:** Each service (Cilium, Redis, Postgres, Monitoring) is deployed as a standalone ArgoCD `Application`.
* **Sync Policies:** Automated pruning and self-healing are enabled to prevent configuration drift.

## 🛡️ DevSecOps & Security (CI/CD)
* **Security Scanning:** Automated pipelines using **Semgrep** (SAST), **Checkov** (IaC), and **Trivy** (Images/Configs).
* **Governance:** Resource quotas are enforced via `app-quota.yaml` (Limits: 2 CPU / 4Gi RAM) to ensure fair resource distribution.
* **GitHub Integration:** Security scan results are uploaded in SARIF format to the GitHub Security tab.

## 🏗️ Infrastructure as Code (Terraform & LocalStack)
* **Terraform:** Modular IaC for cloud resource provisioning.
* **LocalStack (Free Version):** Emulates core AWS services (S3, SQS, Lambda, SNS, DynamoDB) locally within the cluster for cost-effective development.
* **Ingress:** Accessible via `localstack.local` with wildcard support (`*.localstack.local`).

## 🌐 Networking & Observability (Cilium & Hubble)
* **Cilium:** eBPF-powered networking and security.
* **Hubble UI:** Deep network flow observability accessible at `hubble.local`.
* **Network Policies:** Explicit Egress rules (Nginx → Redis) and Ingress rules (Monitoring → Nginx).

## 📊 Monitoring & Metrics (Prometheus & Grafana)
* **Kube-Prometheus-Stack:** Lightweight setup with 1h retention and disabled webhooks for local development performance.
* **Autoscaling:** **HPA** manages Nginx replicas (2 to 10) based on a 70% CPU utilization threshold.

## 🗄️ Storage & Databases (Redis & PostgreSQL)
* **PostgreSQL:** Deployed via Helm-based Application with 8Gi persistent storage.
* **Redis:** High-availability setup with 3 replicas and persistent storage via PVCs.

## 🔑 Secrets Management (Sealed Secrets)
* **Sealed Secrets:** Integrated into the GitOps flow to allow secure storage of encrypted credentials directly in the repository.

## 🚀 Apps & Base Implementation
* **Hardened Nginx:** Uses `nginx-unprivileged` images and restricted security contexts (`runAsNonRoot: true`).
* **RBAC:** A `junior-dev-sa` ServiceAccount with restricted `pod-reader` permissions for secure debugging.

## 🚦 Local Access & Requirements
### Prerequisites
* **Docker Desktop:** Required for the local Kubernetes cluster and container runtime.

### Local Ingress Map (Add to `/etc/hosts`)
```text
127.0.0.1 argocd.local
127.0.0.1 grafana.local
127.0.0.1 hubble.local
127.0.0.1 localstack.local
```

## 🛠️ Troubleshooting

### 🐙 ArgoCD Sync Issues

To get ArgoCD up and running, follow these steps:

1. **Create the namespace:**
   ```bash
   kubectl create namespace argocd
   ```
2. **Install ArgoCD:**
   ```bash
   kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)
   ```
3. **Retrieve the initial admin password:**
   ```bash
   [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}")))
   ```   

If the ArgoCD sync hangs or gets stuck, run the following command to restart the repo server:

```bash
kubectl rollout restart deployment argocd-repo-server -n argocd
```

### ☁️ LocalStack Setup
Using LocalStack requires a personal account. You must create a Kubernetes secret containing your personal authentication token:

```bash
kubectl create secret generic localstack-secrets -n localstack --from-literal=auth-token='YOUR-TOKEN'
```

### 📊 Prometheus Permission Denied
In the event of a "Permission Denied" error in Prometheus (Monitoring stack), follow these steps to clean up the environment:

```bash
kubectl delete application monitoring -n argocd
kubectl delete jobs,pods,deployments,statefulsets --all -n monitoring
```

---

## 📂 Repository Structure

| Directory | Contents |
| :--- | :--- |
| `.github/` | DevSecOps Pipelines & Port Automations |
| `apps/base` | Hardened Nginx manifests (HPA, RBAC, NetPol) |
| `bootstrap/` | ArgoCD Root-App (Platform Entry Point) |
| `infrastructure/` | ArgoCD Apps: Cilium, monitoring, LocalStack, databases, etc. |
| `terraform/` | IaC modules for Cloud & LocalStack provisioning |

---

## 🤝 Contributing
Contributions, ideas, and bug fixes are highly welcome! If you want to help improve this platform, please feel free to open an Issue or submit a Pull Request on GitHub.

---

## 🔮 Future Improvements

* **⚙️ LocalStack Automation:** Manage LocalStack resources directly through Backstage and Terraform.
* **🤖 MLOps/AIOps:** Introduce specialized stacks tailored for MLOps/AIOps workflows.
* **📦 Cluster Bootstrapping:** Add native support for K3S or Minikube to optimize local resource consumption.
* **🔀 Migration to Kubernetes Gateway API:** Transition from traditional Ingress to the modern Gateway API.
* **🔐 Secret Management Integration:** Implement **HashiCorp Vault** integration via **External Secrets Operator (ESO)**.
* **🚀 Progressive Delivery:** Integrate **Argo Rollouts** for Canary and Blue-Green deployments.
* **🔭 Full-Stack Observability:** Complement Prometheus with **Loki** (logs).
* **💾 Disaster Recovery:** Setup **Velero** for automated backups.
* **💸 FinOps & Cost Monitoring:** Integrate **Kubecost** to track and optimize Kubernetes resource spending.
