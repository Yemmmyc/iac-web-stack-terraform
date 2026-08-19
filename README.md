# Infrastructure as Code (IaC) Web Stack with Terraform

![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-Web%20Server-009639?logo=nginx&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-2088FF?logo=githubactions&logoColor=white)
![Cost](https://img.shields.io/badge/Cloud%20Cost-%E2%82%A60-brightgreen)

A reproducible, containerized web infrastructure stack managed through **Infrastructure as Code (IaC)** with Terraform.

The project combines a responsive web interface, Docker, NGINX, Terraform and GitHub Actions to demonstrate how infrastructure can be defined, validated, provisioned, verified and reproduced without relying on manual configuration or paid cloud infrastructure.

> **Project principle:** Define infrastructure as code, validate it automatically, and reproduce the environment consistently instead of configuring infrastructure manually.

---

## 1. Project Overview

This project demonstrates a complete local IaC workflow:

```text
Web Application
      |
      v
   Dockerfile
      |
      v
 Docker Image
      |
      v
   Terraform
      |
      +-- Docker Network
      +-- Docker Image
      +-- Docker Container
              |
              v
             NGINX
              |
              v
       localhost:8090
```

Terraform manages the infrastructure resources while Docker provides the runtime environment and NGINX serves the application.

The project is intentionally designed to run locally using **Windows + WSL2 + Docker**, making it possible to demonstrate infrastructure automation, validation and CI without depending on paid cloud infrastructure.

---

## 2. Nigerian Problem Context

### Problem

Small businesses and growing organisations can initially depend heavily on manual infrastructure configuration. This can lead to:

- inconsistent environments
- configuration drift
- deployment mistakes
- difficult troubleshooting
- longer recovery times
- dependency on individual administrators remembering configuration steps

For organisations operating under tight budgets, infrastructure automation can provide repeatability and reduce unnecessary operational overhead.

### Proposed Solution

This project applies Infrastructure as Code principles to a practical web stack.

Terraform defines the desired infrastructure state. Docker provides the application runtime, while NGINX serves the web application.

The environment follows a repeatable lifecycle:

```text
Defined -> Reviewed -> Validated -> Planned -> Applied
   ^                                             |
   |                                             v
Recreated <- Destroyed <- Verified <- Health Check
```

---

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code and resource lifecycle management |
| Docker | Container runtime |
| NGINX | Web server |
| HTML | Application structure |
| CSS | Application presentation |
| JavaScript | Client-side interactions |
| WSL2 / Ubuntu | Local Linux development environment |
| Git | Source control |
| GitHub | Repository and collaboration |
| GitHub Actions | Automated Terraform validation and CI |

### Terraform Provider

The project uses the community Docker provider:

```text
kreuzwerker/docker
```

The provider version is locked through:

```text
terraform/.terraform.lock.hcl
```

---

## 4. Repository Structure

```text
iac-web-stack-terraform/
|
+-- .github/
|   +-- workflows/
|       +-- terraform.yml
|
+-- app/
|   +-- index.html
|   +-- script.js
|   +-- style.css
|
+-- docs/
|   +-- ARCHITECTURE.md
|
+-- terraform/
|   +-- .terraform.lock.hcl
|   +-- main.tf
|   +-- outputs.tf
|   +-- provider.tf
|   +-- variables.tf
|   +-- versions.tf
|
+-- .dockerignore
+-- .gitignore
+-- Dockerfile
+-- README.md
```

Terraform state and the local `.terraform` directory are intentionally excluded from version control.

---

## 5. Infrastructure Resources

Terraform provisions three primary resources.

### Docker Network

```text
iac-web-network
```

A dedicated bridge network provides an explicit network boundary for the application container.

### Docker Image

```text
iac-web-stack:local
```

The image packages the application and NGINX configuration defined by the Dockerfile.

### Docker Container

```text
iac-web-stack
```

The container runs the web application and exposes:

```text
Host:      8090
Container: 80
```

The resulting local URL is:

```text
http://localhost:8090
```

---

## 6. Health Monitoring

The container includes a Docker health check that tests the NGINX endpoint:

```text
GET http://localhost/
```

The health check uses `wget` with retries and a timeout.

A successful deployment reports:

```text
healthy
```

This provides infrastructure-level verification that the web server is responding inside the container.

---

## 7. Local Setup

### Prerequisites

Install or enable:

- Windows 10/11 with WSL2
- Ubuntu
- Docker
- Terraform
- Git

Verify the tools:

```bash
wsl --version
docker --version
terraform version
git --version
```

Confirm Docker is available:

```bash
docker info
```

---

## 8. Run the Project

Clone the repository:

```bash
git clone https://github.com/Yemmmyc/iac-web-stack-terraform.git
cd iac-web-stack-terraform
```

Initialize Terraform:

```bash
terraform -chdir=terraform init
```

Format the Terraform configuration:

```bash
terraform -chdir=terraform fmt -recursive
```

Validate the configuration:

```bash
terraform -chdir=terraform validate
```

Review the proposed infrastructure:

```bash
terraform -chdir=terraform plan
```

Apply the infrastructure:

```bash
terraform -chdir=terraform apply
```

When prompted, enter:

```text
yes
```

---

## 9. Verify the Deployment

Check the Terraform outputs:

```bash
terraform -chdir=terraform output
```

Expected outputs include:

```text
application_url = "http://localhost:8090"
container_name  = "iac-web-stack"
network_name    = "iac-web-network"
```

Check the running container:

```bash
docker ps --filter "name=iac-web-stack"
```

Check the health status:

```bash
docker inspect --format='{{.State.Health.Status}}' iac-web-stack
```

Expected:

```text
healthy
```

Verify the HTTP endpoint:

```bash
curl -I http://localhost:8090
```

Expected:

```text
HTTP/1.1 200 OK
```

The implementation was successfully verified locally with a healthy Docker container and an HTTP 200 response from NGINX.

---

## 10. Terraform Lifecycle

### Initialize

```bash
terraform -chdir=terraform init
```

### Format

```bash
terraform -chdir=terraform fmt -recursive
```

### Validate

```bash
terraform -chdir=terraform validate
```

### Plan

```bash
terraform -chdir=terraform plan
```

### Apply

```bash
terraform -chdir=terraform apply
```

### Inspect

```bash
terraform -chdir=terraform show
terraform -chdir=terraform output
```

### Destroy

When the environment is no longer required:

```bash
terraform -chdir=terraform destroy
```

This removes the Terraform-managed Docker resources.

---

## 11. CI with GitHub Actions

The repository includes:

```text
.github/workflows/terraform.yml
```

The workflow runs on pushes and pull requests targeting `main`.

It performs:

```text
Checkout
   |
   v
Install Terraform
   |
   v
Terraform fmt -check
   |
   v
Terraform init
   |
   v
Terraform validate
   |
   v
Terraform plan
```

### CI Result

The GitHub Actions Terraform validation workflow successfully passed:

```text
Terraform Format Check     PASS
Terraform Init             PASS
Terraform Validate         PASS
Terraform Plan             PASS
```

The workflow validates infrastructure changes and generates a plan without applying infrastructure from GitHub Actions.

This provides a CI quality gate while keeping infrastructure deployment under controlled execution.

---

## 12. Security and Repository Hygiene

The repository excludes local Terraform state and environment-specific files through `.gitignore`.

Examples include:

```text
*.tfstate
*.tfstate.*
.terraform/
*.tfvars
.env
```

Terraform provider selections are retained through:

```text
terraform/.terraform.lock.hcl
```

No cloud credentials or infrastructure secrets should be committed to the repository.

---

## 13. Design Decisions

### Local-first architecture

The project uses local infrastructure so the complete IaC workflow can be demonstrated without creating unnecessary cloud costs.

### Terraform-managed Docker resources

Instead of manually executing:

```bash
docker run ...
docker network create ...
```

the desired infrastructure is declared in Terraform.

This makes the environment reproducible, reviewable and easier to recreate.

### Health checks

The container health check provides an automated signal that the web service is operational.

### CI validation

GitHub Actions automatically checks formatting, initialization, validation and planning.

### Separation of concerns

The web application lives under `app/`, the image definition is represented by `Dockerfile`, and infrastructure definitions live under `terraform/`.

---

## 14. Final Architecture

```text
                         GitHub Repository
                                |
                    push / pull request
                                |
                                v
                       GitHub Actions CI
                                |
              +-----------------+-----------------+
              |                 |                 |
              v                 v                 v
        fmt -check           init             validate
              |                 |                 |
              +-----------------+-----------------+
                                |
                                v
                              plan
                                |
                                v
                       Terraform Configuration
                                |
                                v
                       Docker Provider
                                |
             +------------------+------------------+
             |                  |                  |
             v                  v                  v
       Docker Network      Docker Image      Docker Container
       iac-web-network     iac-web-stack:     iac-web-stack
                           local                    |
                                                    v
                                                   NGINX
                                                    |
                                                    v
                                           Web Application
                                                    |
                                                    v
                                         http://localhost:8090
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the detailed architecture documentation.

---

## 15. Completed Implementation

The project has progressed from an initial local web application to a working Terraform-managed IaC solution with CI validation.

Completed capabilities:

- [x] Responsive web application
- [x] Dockerized application
- [x] NGINX web server
- [x] Terraform provider configuration
- [x] Terraform-managed Docker network
- [x] Terraform-managed Docker image
- [x] Terraform-managed Docker container
- [x] Container health check
- [x] Terraform formatting validation
- [x] Terraform initialization
- [x] Terraform validation
- [x] Terraform plan
- [x] Terraform apply
- [x] Terraform state tracking
- [x] Deployment verification with Docker
- [x] HTTP endpoint verification
- [x] Git repository
- [x] GitHub repository
- [x] GitHub Actions workflow
- [x] Automated Terraform CI validation
- [x] Architecture documentation
- [x] Project README documentation

---

## 16. Project Status

**Current status: Completed capstone implementation**

The core project objectives have been achieved.

The final implementation demonstrates:

```text
Application
     |
     v
Docker
     |
     v
Terraform
     |
     v
Infrastructure
     |
     v
Health Verification
     |
     v
GitHub Actions CI
     |
     v
Documented, Reproducible IaC Workflow
```

The repository is ready for final portfolio presentation and submission.

---

## 17. Future Enhancements

The core project is complete. The following are optional extensions rather than outstanding requirements:

- public cloud deployment
- remote Terraform state
- environment-specific configuration
- additional security scanning
- automated release/versioning
- more extensive application smoke testing
- production-grade observability
- additional CI/CD deployment stages

These enhancements are deliberately separated from the completed capstone scope.

---

## 18. Author

**Oluwayemisi Okunrounmu**

IT Technical Support | Infrastructure | Cloud | DevOps

**3MTT NextGen Cohort Capstone Project**

**Fellow ID:** FE/23/34540833

GitHub: [@Yemmmyc](https://github.com/Yemmmyc)
