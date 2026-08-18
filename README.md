# Infrastructure as Code (IaC) Web Stack with Terraform

![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-Web%20Server-009639?logo=nginx&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-2088FF?logo=githubactions&logoColor=white)
![Cost](https://img.shields.io/badge/Cloud%20Cost-%E2%82%A60-brightgreen)

A reproducible, containerized web infrastructure stack managed through **Infrastructure as Code (IaC)** with Terraform.

The project combines a responsive web interface, Docker, NGINX and Terraform to demonstrate how infrastructure can be defined, validated, provisioned, verified and reproduced without relying on manual configuration.

> **Project principle:** Define infrastructure as code, validate it automatically, and reproduce the environment consistently instead of configuring infrastructure manually.

---

## 1. Project Overview

This project demonstrates a small but production-minded infrastructure workflow:

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

The project is intentionally designed to run locally using **Windows + WSL2 + Docker**, making it possible to demonstrate IaC practices without depending on paid cloud infrastructure.

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

The environment can therefore follow a repeatable lifecycle:

```text
Defined
   |
   v
Reviewed
   |
   v
Validated
   |
   v
Planned
   |
   v
Applied
   |
   v
Verified
   |
   v
Destroyed
   |
   v
Recreated
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
| GitHub Actions | Automated Terraform validation |

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

A dedicated bridge network provides an isolated network for the application container.

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

The health check uses `wget` and is configured with retries and a timeout.

A successful deployment reports:

```text
healthy
```

This provides a simple infrastructure-level verification that the web server is responding inside the container.

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

---

## 10. Terraform Lifecycle

The project demonstrates the basic Terraform lifecycle:

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

The current CI workflow runs on pushes and pull requests targeting `main`.

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

This ensures that infrastructure changes are automatically checked before they are accepted into the project.

### Current CI Result

The Terraform validation workflow has successfully completed:

```text
Terraform Format Check     PASS
Terraform Init             PASS
Terraform Validate         PASS
Terraform Plan             PASS
```

The workflow is intentionally limited to validation and planning. It does **not** deploy infrastructure from GitHub Actions.

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

The project deliberately uses local infrastructure so that the complete IaC workflow can be demonstrated without creating unnecessary cloud costs.

### Terraform-managed Docker resources

Rather than manually running:

```bash
docker run ...
docker network create ...
```

the project defines the desired infrastructure in Terraform.

This makes the environment reproducible and reviewable.

### Health checks

The container health check provides a simple automated signal that the web service is operational.

### CI validation before deployment

GitHub Actions validates the Terraform configuration and generates a plan without changing infrastructure.

This creates a safer foundation for a future deployment stage.

---

## 14. Current Architecture

```text
                    GitHub
                       |
                       | push / pull request
                       v
               GitHub Actions
                       |
             Terraform validation
                       |
          +------------+------------+
          |                         |
       fmt-check                 validate
          |                         |
          +------------+------------+
                       |
                     plan
                       |
                       v
                Terraform Code
                       |
                       v
                 Docker Provider
                       |
          +------------+------------+
          |            |            |
          v            v            v
       Network       Image       Container
          |            |            |
          +------------+------------+
                       |
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

## 15. Future Improvements

Planned improvements include:

- Docker image build validation in CI
- automated application smoke testing
- improved deployment automation
- public hosting/deployment for external access
- architecture diagram and project screenshots
- stronger security scanning
- optional remote Terraform state
- environment-specific configuration
- automated release/versioning

The goal is to evolve the project from a local IaC demonstration into a more complete CI/CD and deployment reference architecture.

---

## 16. Project Status

**Current status: Active development**

Implemented:

- [x] Responsive web application
- [x] Dockerized application
- [x] NGINX web server
- [x] Terraform provider configuration
- [x] Terraform-managed Docker network
- [x] Terraform-managed Docker image
- [x] Terraform-managed Docker container
- [x] Container health check
- [x] Terraform validation
- [x] Terraform plan
- [x] Git repository
- [x] GitHub repository
- [x] GitHub Actions Terraform CI

Next:

- [ ] Docker CI validation
- [ ] Architecture documentation
- [ ] Public deployment
- [ ] Final portfolio presentation

---

## 17. Author

**Oluwayemisi Okunrounmu**

IT Technical Support | Infrastructure | Cloud | DevOps

**3MTT NextGen Cohort Capstone Project**
**Fellow ID  FE/23/34540833**

GitHub: [@Yemmmyc](https://github.com/Yemmmyc)

Repository: [iac-web-stack-terraform](https://github.com/Yemmmyc/iac-web-stack-terraform)
