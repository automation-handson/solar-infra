# Solar System Nodejs Application
An end-to-end DevOps ecosystem that shows my experience on how to build devops ecosystem from scratch

This Repo Serves as the Infrastructure Repo (2/3) for the DevOps ecosystem:

1. [solar-app](https://github.com/automation-handson/solar-app)
2. [solar-infra](https://github.com/automation-handson/solar-infra)
3. [solar-gitops](https://github.com/automation-handson/solar-gitops)

## Application Stack
1. NodeJS
2. ExpressJS
3. Mongodb
4. Mocha, Chai, Chai-http, and nyc for Testing
5. Docker

## DevOps EcoSystem
1. Terraform --> Infrastructure As A Code
2. AWS --> Cloud Infrastructure
3. Docker --> Containerization
4. Kubernetes --> Container Orchestration
5. Helm --> Kubernetes Package Management, and Argocd Source
6. Jenkins --> CD/CD Pipeline
7. ArgoCD --> GitOps auto-deployment
8. Hashicorp Vault --> Secrets Management
9. Sonarqube --> Code Quality & vulnerability check
10. Postgres --> Sonarqube backend
11. Trivy --> Docker Images Vulnerability check
12. Kaniko --> Build Container Images
13. Prometheus, and Grafana --> Monitoring Stack


### Manual Steps
1. Buy the domain
2. Configure Azure entraID by creating groups and users
3. create TLS certs for Vault and put them in infra Repo and Terraform will handel the rest

### Bridging the Gap Between Infra and GitOps
1- Terraform will read the TLS directory in the infra Repo that contains the TLS certificates and the Vault license and create k8s secret and get read by the GitOps approach 