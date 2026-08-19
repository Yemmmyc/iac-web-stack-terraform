# Architecture Documentation

## Infrastructure as Code (IaC) Web Stack with Terraform

**Project:** iac-web-stack-terraform  
**Author:** Oluwayemisi Okunrounmu  
**Programme:** 3MTT NextGen Cohort Capstone Project  
**Fellow ID:** FE/23/34540833

---

## 1. Architecture Overview

The project implements a local, reproducible web infrastructure stack using Terraform and Docker.

The architecture separates the application layer from the infrastructure layer:

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

Terraform is responsible for declaring and managing the Docker infrastructure. Docker provides the runtime. NGINX serves the application.

---

## 2. Architecture Goals

The architecture was designed around these goals:

1. **Reproducibility** — infrastructure should be recreated from code.
2. **Consistency** — avoid manual Docker configuration.
3. **Validation** — detect Terraform configuration problems before deployment.
4. **Verification** — provide a health check and HTTP verification.
5. **Low cost** — demonstrate the complete workflow locally.
6. **Maintainability** — separate application, container and infrastructure concerns.
7. **CI integration** — automatically validate infrastructure changes through GitHub Actions.

---

## 3. Component Architecture

### 3.1 Application Layer

The application is contained in:

```text
app/
├── index.html
├── style.css
└── script.js
```

Responsibilities:

- `index.html` provides the page structure and content.
- `style.css` provides presentation and responsive styling.
- `script.js` provides client-side interaction.

---

### 3.2 Container Image Layer

The root `Dockerfile` defines the application image.

The image packages:

```text
Web Application
      +
NGINX
      |
      v
iac-web-stack:local
```

The resulting Docker image is managed by Terraform.

---

### 3.3 Web Server Layer

NGINX runs inside the Docker container.

Its role is to:

- serve the static web application
- listen on container port `80`
- provide the HTTP endpoint tested by the container health check

The application is accessed through:

```text
http://localhost:8090
```

---

### 3.4 Terraform Layer

Terraform is the infrastructure orchestration layer.

The configuration is located in:

```text
terraform/
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf
├── versions.tf
└── .terraform.lock.hcl
```

Terraform declares the desired Docker infrastructure and reconciles the local environment with that configuration.

---

## 4. Terraform Resource Model

The project provisions three primary Docker resources.

### 4.1 Docker Network

Resource:

```text
docker_network.web_network
```

Resulting network:

```text
iac-web-network
```

Configuration:

```text
Driver: bridge
Scope:  local
```

The network gives the application container a dedicated Docker network.

---

### 4.2 Docker Image

Resource:

```text
docker_image.web_image
```

Image:

```text
iac-web-stack:local
```

The image is built from the project's Dockerfile and retained locally.

---

### 4.3 Docker Container

Resource:

```text
docker_container.web
```

Container name:

```text
iac-web-stack
```

Port mapping:

```text
Host port       Container port
-----------     --------------
8090      --->  80
```

The container is configured to restart unless stopped manually.

It also carries project metadata labels:

```text
project     = iac-web-stack
managed-by  = terraform
environment = local
```

---

## 5. Container Health Architecture

The container contains an automated health check.

The check executes:

```text
wget --no-verbose --tries=1 --spider http://localhost/
```

The health check is configured with:

```text
Interval: 30 seconds
Timeout:  5 seconds
Retries:  3
```

The expected healthy state is:

```text
healthy
```

This distinguishes:

```text
Container is running
```

from:

```text
Web service is responding
```

---

## 6. Network Flow

The request path is:

```text
Browser / curl
      |
      | HTTP :8090
      v
Docker host
      |
      | port mapping
      v
iac-web-stack container
      |
      | HTTP :80
      v
NGINX
      |
      v
Static web application
```

The Docker container is attached to:

```text
iac-web-network
```

---

## 7. Infrastructure Lifecycle

The intended lifecycle is:

```text
Terraform Configuration
          |
          v
        init
          |
          v
        fmt
          |
          v
      validate
          |
          v
         plan
          |
          v
        apply
          |
          v
     Docker Resources
          |
          v
       Health Check
          |
          v
     HTTP Verification
          |
          v
       Application
```

When the environment is no longer required:

```bash
terraform -chdir=terraform destroy
```

removes the Terraform-managed Docker resources.

The environment can subsequently be recreated with:

```bash
terraform -chdir=terraform apply
```

---

## 8. CI/CD Architecture

The repository contains:

```text
.github/workflows/terraform.yml
```

The workflow is triggered by:

- pushes to `main`
- pull requests targeting `main`

The CI sequence is:

```text
GitHub Event
     |
     v
Checkout
     |
     v
Setup Terraform
     |
     v
terraform fmt -check
     |
     v
terraform init
     |
     v
terraform validate
     |
     v
terraform plan
```

### CI Responsibilities

#### Formatting

```bash
terraform fmt -check -recursive
```

Ensures Terraform configuration follows canonical formatting.

#### Initialization

```bash
terraform init -input=false
```

Initializes Terraform and installs the locked provider version.

#### Validation

```bash
terraform validate
```

Checks the configuration for syntax and internal consistency.

#### Planning

```bash
terraform plan -input=false
```

Calculates infrastructure changes without applying them.

---

## 9. CI Boundary

The current GitHub Actions workflow deliberately stops at planning:

```text
CI
 |
 +-- fmt
 +-- init
 +-- validate
 +-- plan
 |
 STOP
```

It does not automatically execute:

```text
terraform apply
```

This is intentional. Automated validation is separated from infrastructure mutation so that deployment remains under deliberate operator control.

---

## 10. Terraform State

Terraform maintains state locally during development.

The state represents resources managed by Terraform, including:

```text
docker_container.web
docker_image.web_image
docker_network.web_network
```

The repository `.gitignore` excludes:

```text
*.tfstate
*.tfstate.*
.terraform/
```

The provider lock file is retained:

```text
terraform/.terraform.lock.hcl
```

This supports consistent provider selection.

---

## 11. Security Considerations

The project follows basic security and repository hygiene practices.

### Secrets exclusion

The repository excludes:

```text
*.tfvars
.env
.env.*
```

### State exclusion

Terraform state is excluded from Git.

### Provider locking

The Docker provider selection is recorded in:

```text
terraform/.terraform.lock.hcl
```

### Local-first execution

The core implementation does not require cloud credentials.

---

## 12. Repository Architecture

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

Separation of concerns:

```text
app/          Application
Dockerfile    Container image definition
terraform/    Infrastructure definition
.github/      CI automation
docs/         Documentation
```

---

## 13. Verification Architecture

The implementation uses multiple levels of verification.

### Terraform-level

```bash
terraform -chdir=terraform validate
```

### Infrastructure-level

```bash
terraform -chdir=terraform show
terraform -chdir=terraform output
```

### Container-level

```bash
docker ps --filter "name=iac-web-stack"
```

### Health-level

```bash
docker inspect --format='{{.State.Health.Status}}' iac-web-stack
```

Expected:

```text
healthy
```

### Application-level

```bash
curl -I http://localhost:8090
```

Expected:

```text
HTTP/1.1 200 OK
```

Verification therefore progresses through:

```text
Terraform
   |
   v
Infrastructure
   |
   v
Container
   |
   v
Health Check
   |
   v
HTTP Application
```

---

## 14. Design Decisions

### Local-first

A local Docker environment was selected to make the project reproducible without paid cloud resources.

### Declarative infrastructure

Terraform describes the desired state rather than relying on manually executed Docker commands.

### Dedicated network

A named Docker bridge network provides an explicit network boundary for the application.

### Health check

The health check verifies application availability inside the container rather than relying only on process status.

### CI validation

GitHub Actions provides automated infrastructure quality checks for repository changes.

### No automatic apply in CI

The CI pipeline stops at `plan`, keeping infrastructure mutation under deliberate operator control.

---

## 15. Operational Workflow

```text
Developer changes code
        |
        v
Git commit
        |
        v
GitHub push / pull request
        |
        v
GitHub Actions
        |
        +--> fmt check
        |
        +--> init
        |
        +--> validate
        |
        +--> plan
        |
        v
Review
        |
        v
Terraform apply
        |
        v
Docker resources
        |
        v
Health verification
        |
        v
HTTP verification
```

This combines source control, automated validation and reproducible infrastructure management.

---

## 16. Completed Architecture Objectives

- [x] Application packaged in Docker
- [x] NGINX web serving
- [x] Terraform Docker provider
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
- [x] Docker runtime verification
- [x] HTTP application verification
- [x] GitHub repository integration
- [x] GitHub Actions Terraform CI
- [x] Architecture documentation

---

## 17. Final State

```text
                         SOURCE CONTROL
                              |
                              v
                     GitHub Repository
                              |
                              v
                      GitHub Actions
                              |
                   Terraform CI Validation
                              |
                              v
                    Terraform Configuration
                              |
                              v
                       Docker Provider
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
          Network           Image          Container
             |                |                |
             +----------------+----------------+
                              |
                              v
                            NGINX
                              |
                              v
                       Web Application
                              |
                              v
                    localhost:8090
                              |
                              v
                         HTTP 200 OK
                              |
                              v
                    HEALTHY CONTAINER
```

The completed architecture provides a practical demonstration of Infrastructure as Code, containerization, automated validation and operational verification.

---

## 18. Future Extensions

The current capstone architecture is complete. Possible future extensions include:

- remote Terraform state
- environment-specific configurations
- public cloud deployment
- stronger security scanning
- automated release/versioning
- production-grade observability
- additional deployment stages

These are enhancements to the completed architecture rather than unresolved project requirements.
