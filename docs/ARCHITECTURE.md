# IaC Web Stack — Architecture Documentation

## 1. Purpose

This document describes the architecture, infrastructure components, request flow and operational lifecycle of the **Infrastructure as Code (IaC) Web Stack with Terraform**.

The project demonstrates how a small web application can be packaged, provisioned and managed through reproducible infrastructure definitions.

---

## 2. High-Level Architecture

```text
                         +-----------------------+
                         |        GitHub         |
                         |   Source Repository   |
                         +-----------+-----------+
                                     |
                              push / pull request
                                     |
                                     v
                         +-----------------------+
                         |    GitHub Actions     |
                         |                       |
                         | Terraform fmt-check   |
                         | Terraform init        |
                         | Terraform validate    |
                         | Terraform plan        |
                         +-----------+-----------+
                                     |
                              Terraform code
                                     |
                                     v
                         +-----------------------+
                         |      Terraform        |
                         |                       |
                         |  Docker Provider      |
                         +-----------+-----------+
                                     |
                +--------------------+--------------------+
                |                    |                    |
                v                    v                    v
       +----------------+   +----------------+   +-----------------+
       | Docker Network |   |  Docker Image  |   | Docker Container|
       |                |   |                |   |                 |
       | iac-web-network|   |iac-web-stack   |   | iac-web-stack   |
       +----------------+   +----------------+   +--------+--------+
                                                          |
                                                          v
                                                   +-------------+
                                                   |    NGINX    |
                                                   | Port 80     |
                                                   +------+------+
                                                          |
                                                          v
                                               +------------------+
                                               | Web Application  |
                                               | HTML/CSS/JS      |
                                               +--------+---------+
                                                        |
                                                        v
                                               Host port 8090
                                                        |
                                                        v
                                           http://localhost:8090
```

---

## 3. Runtime Environment

The local runtime consists of:

```text
Windows
   |
   v
WSL2
   |
   v
Ubuntu
   |
   v
Docker Engine
   |
   v
Terraform-managed resources
```

This arrangement provides a Linux-based development environment while allowing the application to be accessed from the Windows host through the published Docker port.

---

## 4. Application Layer

The application is contained in:

```text
app/
+-- index.html
+-- style.css
+-- script.js
```

### index.html

Provides the structure and content of the web interface.

### style.css

Provides the visual design, responsive layout and presentation.

### script.js

Provides client-side interaction.

The application is packaged into the Docker image rather than being served directly from the host filesystem.

---

## 5. Container Layer

The Dockerfile defines how the application image is built.

The resulting image is:

```text
iac-web-stack:local
```

The image contains the web application and NGINX runtime.

NGINX listens on:

```text
Container port: 80
```

Terraform publishes the container port to:

```text
Host port: 8090
```

Therefore:

```text
Browser
   |
   v
localhost:8090
   |
   v
Docker port mapping
   |
   v
Container:80
   |
   v
NGINX
```

---

## 6. Infrastructure Layer

Terraform manages three primary Docker resources.

### 6.1 Docker Network

Resource:

```text
docker_network.web_network
```

Name:

```text
iac-web-network
```

Driver:

```text
bridge
```

The network provides a dedicated Docker networking boundary for the application.

---

### 6.2 Docker Image

Resource:

```text
docker_image.web_image
```

Name:

```text
iac-web-stack:local
```

Terraform ensures that the required image exists before the application container is created.

---

### 6.3 Docker Container

Resource:

```text
docker_container.web
```

Name:

```text
iac-web-stack
```

The container:

- uses the Terraform-managed image
- connects to the Terraform-managed network
- publishes port 80 to host port 8090
- uses a restart policy
- exposes Docker labels for identification
- includes an HTTP health check

---

## 7. Container Health Check

The container uses a health check equivalent to:

```text
wget --no-verbose --tries=1 --spider http://localhost/
```

The health check verifies the NGINX endpoint from inside the container.

The desired state is:

```text
healthy
```

This is separate from Terraform validation.

### Terraform validation

Answers:

> Is the infrastructure configuration syntactically and semantically valid?

### Docker health check

Answers:

> Is the web service actually responding inside the running container?

Together they provide stronger verification.

---

## 8. Infrastructure Lifecycle

The intended lifecycle is:

```text
Terraform configuration
          |
          v
       terraform fmt
          |
          v
      terraform validate
          |
          v
       terraform plan
          |
          v
      terraform apply
          |
          v
 Docker resources created
          |
          v
   Container health check
          |
          v
     HTTP smoke test
          |
          v
      Infrastructure
        operational
```

To remove the environment:

```text
terraform destroy
       |
       v
Docker container removed
       |
       v
Docker network removed
       |
       v
Managed infrastructure gone
```

The environment can subsequently be recreated with `terraform apply`.

---

## 9. CI Architecture

GitHub Actions provides the current continuous integration layer.

```text
Developer
   |
   v
git push / pull request
   |
   v
GitHub
   |
   v
GitHub Actions
   |
   +-- Checkout
   |
   +-- Setup Terraform
   |
   +-- terraform fmt -check
   |
   +-- terraform init
   |
   +-- terraform validate
   |
   +-- terraform plan
```

The CI workflow does **not** currently deploy the application.

This is intentional.

The GitHub-hosted runner has its own Docker environment and is not the same Docker daemon running inside the developer's WSL2 environment.

Keeping the current workflow focused on validation avoids coupling the public CI runner to the developer's local infrastructure.

---

## 10. State Management

Terraform maintains a local state file during development.

The state records resources managed by Terraform, including:

```text
docker_container.web
docker_image.web_image
docker_network.web_network
```

Local state files are excluded from Git version control.

The provider lock file is committed:

```text
terraform/.terraform.lock.hcl
```

This allows Terraform to consistently select the tested provider version.

---

## 11. Security Boundaries

The project currently uses a local development architecture.

Important security practices include:

- no credentials stored in Terraform files
- no `.env` files committed
- Terraform state excluded from Git
- Terraform variable files excluded by `.gitignore`
- CI uses read-only repository permissions
- infrastructure deployment is not performed automatically by the current CI workflow

For a production deployment, additional controls would be appropriate, including:

- secret management
- remote state with locking
- least-privilege cloud identity
- image vulnerability scanning
- HTTPS/TLS
- dependency scanning
- network restrictions
- deployment approvals

---

## 12. Why Terraform?

The project could be started manually with Docker commands, but manual commands do not provide the same declarative infrastructure model.

Terraform allows the desired state to be expressed as code.

The configuration describes a desired state where:

```text
network exists
image exists
container exists
container uses the image
container joins the network
port 8090 maps to port 80
health check is configured
```

Terraform then compares the desired state with the current state and determines the required actions.

---

## 13. Reproducibility

A major goal is that the environment should not depend on undocumented manual steps.

A new developer should be able to:

```text
Clone repository
      |
      v
Install prerequisites
      |
      v
terraform init
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
terraform apply
      |
      v
Access localhost:8090
```

This is the core value of the project.

---

## 14. Current Verification Evidence

The infrastructure has been successfully tested locally.

### Terraform

```text
terraform validate
Success! The configuration is valid.
```

### Docker

```text
iac-web-stack
Up ... (healthy)
```

### HTTP

```text
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html
```

### Terraform resources

The deployed state contains:

```text
docker_container.web
docker_image.web_image
docker_network.web_network
```

### CI

GitHub Actions successfully completed:

```text
Terraform Format Check
Terraform Init
Terraform Validate
Terraform Plan
```

---

## 15. Future Architecture

The next evolution of the project can introduce:

```text
Developer
    |
    v
GitHub
    |
    v
CI ----> Test ----> Security Scan
    |
    v
Container Image
    |
    v
Container Registry
    |
    v
Deployment Platform
    |
    v
Public HTTPS URL
```

Possible future components include a container registry, public hosting, HTTPS, remote Terraform state and deployment approvals.

The exact deployment platform should be selected based on project requirements, cost constraints and hackathon rules.

---

## 16. Architecture Summary

The project demonstrates a complete foundational IaC workflow:

```text
Code
 |
 v
Version Control
 |
 v
CI Validation
 |
 v
Terraform Plan
 |
 v
Infrastructure Provisioning
 |
 v
Container Health
 |
 v
Application Verification
```

The architecture deliberately separates **infrastructure definition**, **application packaging**, **runtime execution** and **continuous integration**.

