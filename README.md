# ECS Memos Deployment Project

A production-ready deployment of [Memos](https://www.usememos.com/) on AWS ECS using Docker, Terraform, and GitHub Actions CI/CD. Built as part of the **CoderCo ECS Project**.

## Overview

This project demonstrates a complete production deployment workflow, transitioning from manual AWS setup (ClickOps) to Infrastructure as Code (IaC) with automated CI/CD pipelines. The application is deployed on AWS ECS Fargate with HTTPS, custom domain, and persistent storage.

**Final URL**: https://tm.tomakady.com

## Architecture

<img src="docs/images/memos-dark.drawio.svg" alt="Memos Architecture Diagram - Dark Theme" width="800">

<img src="docs/images/memos-light.drawio.svg" alt="Memos Architecture Diagram - Light Theme" width="800">

## Project Structure

```
ecs-memos/
├── app/                          # Application code
│   └── Dockerfile               # Dockerfile
|
├── infra/                       # Terraform infrastructure
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output values
│   ├── provider.tf              # AWS provider configuration
│   └── modules/                 # Reusable Terraform modules
|       |
│       ├── vpc/                 # VPC, subnets, NAT gateway
│       ├── ecs/                 # ECS cluster and service
│       ├── alb/                 # Application Load Balancer
│       ├── ecr/                 # ECR repository
│       ├── acm/                 # SSL certificate
│       ├── route53/             # DNS configuration
│       ├── efs/                 # Elastic File System
│       ├── sg/                  # Security groups
│       └── iam/                 # IAM roles and policies
|
├── .github/workflows/           # GitHub Actions workflows
│   ├── create-backend.yaml      # Setup Terraform backend (S3, DynamoDB)
│   ├── destroy-backend.yaml     # Backend infrastructure teardown
│   ├── docker-build.yaml        # Docker build and deploy
│   ├── docker-destroy.yaml      # Docker image deletion and service scale-down
│   ├── terraform-apply.yaml     # Terraform infrastructure deployment
│   ├── terraform-plan.yaml      # Terraform plan
│   ├── terraform-validate.yaml  # Terraform validation
│   └── terraform-destroy.yaml   # Terraform infrastructure teardown
│
├── scripts/                     # Local automation scripts
│   ├── create-backend.sh        # Create Terraform backend locally
│   ├── destroy-backend.sh       # Destroy Terraform backend locally
│   ├── terraform-apply.sh       # Run terraform apply locally
│   ├── terraform-destroy.sh     # Run terraform destroy locally
│   ├── docker-build.sh          # Build and deploy Docker image locally
│   └── docker-destroy.sh        # Delete Docker images and scale down service
│
└── README.md
```

## Features

### Infrastructure

- **VPC** with public and private subnets across 2 AZs
- **ECS Fargate** cluster with auto-scaling
- **Application Load Balancer** with HTTPS (port 443) and HTTP to HTTPS redirect
- **ECR** repository for container images
- **ACM** certificate with DNS validation
- **Route 53** DNS record (tm.tomakady.com) pointing to ALB
- **EFS** for persistent storage
- **Security Groups** with least-privilege access
- **IAM Roles** for ECS tasks and GitHub Actions (OIDC)
- **CloudWatch** logging
- **S3 Backend** with DynamoDB locking for Terraform state

### CI/CD

- **Separated Pipelines**: Build/deploy workflows with `workflow_dispatch` triggers
- **Docker Build**: Multi-stage build (frontend with pnpm, backend with Go) and pushes images to ECR with SHA-based tagging
- **Docker Destroy**: Delete Docker images and scale down ECS service (preserves DNS records)
- **Terraform Automation**: Plan, validate, and apply workflows with state management
- **OIDC Authentication**: GitHub Actions uses OIDC for secure AWS access (no long-lived credentials)
- **Health Checks**: Post-deployment verification
- **Terraform Validation**: Includes `fmt`, `validate`, and `tflint` steps
- **Local Scripts**: Bash scripts for running Terraform and Docker operations locally

### Application

- **Multi-stage Docker Build**: 
  - Frontend: Node.js 20 with pnpm for dependency management
  - Backend: Go 1.23+ with automatic toolchain version management (GOTOOLCHAIN=auto)
  - Optimized layer caching and minimal final image size
- **Health Check Endpoint**: `/healthz` returns "Service ready."
- **HTTPS Enabled**: Secure connection with custom domain
- **Persistent Storage**: Data persistence via EFS mounted volume

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Terraform >= 1.0
- Docker (for local testing)
- Domain name registered (for Route 53)
- GitHub repository with Actions enabled

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/tomakady/ecs-memos.git
cd ecs-memos
```

### 2. Configure Terraform Variables

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
project_name = "memos"
environment  = "dev"
aws_region   = "eu-west-2"
domain_name  = "yourdomain.com"
# ... other variables
```

### 3. Configure Terraform Backend

Update `infra/provider.tf` with your S3 bucket and DynamoDB table:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "memos/terraform.tfstate"
  region         = "eu-west-2"
  dynamodb_table = "your-terraform-locks"
  encrypt        = true
}
```

### 4. Configure GitHub Actions

**Initial Setup (One-time)**:

Set up GitHub Secrets for backend creation (only needed once):

- `AWS_ACCESS_KEY_ID`: AWS access key (for initial bootstrap)
- `AWS_SECRET_ACCESS_KEY`: AWS secret key (for initial bootstrap)

**OIDC Configuration (Recommended)**:

After initial setup, all workflows use OIDC authentication via IAM roles (no long-lived credentials needed).

1. Enable OIDC in Terraform by setting in `terraform.tfvars`:
   ```hcl
   enable_github_oidc = true
   github_repo       = "your-username/your-repo"
   ```

2. Add GitHub Secret:
   - `AWS_ROLE_TO_ASSUME`: The ARN of the GitHub Actions role (output from `terraform apply`)

3. All workflows already include OIDC configuration:
   ```yaml
   permissions:
     id-token: write
     contents: read
   ```

### 5. Domain Configuration

1. Create a hosted zone in Route 53 for your domain
2. Update your domain's nameservers at your registrar
3. Terraform will automatically create the `tm.yourdomain.com` record

### 6. Deploy Infrastructure

#### Option A: GitHub Actions (Recommended)

1. **Setup Backend**: Run `create-backend.yaml` workflow manually via `workflow_dispatch`
2. **Deploy Infrastructure**: Run `terraform-apply.yaml` workflow manually via `workflow_dispatch`
3. **Build and Deploy App**: Run `docker-build.yaml` workflow manually via `workflow_dispatch`

#### Option B: Local Scripts

Use the provided scripts in the `scripts/` directory in this order:

1. `create-backend.sh` - Create Terraform backend
2. `terraform-apply.sh` - Deploy infrastructure
3. `docker-build.sh` - Build and deploy application

#### Option C: Manual Deployment

```bash
cd infra
terraform init
terraform plan -var="enable_github_oidc=true" -var="github_repo=your-username/your-repo"
terraform apply -var="enable_github_oidc=true" -var="github_repo=your-username/your-repo"
```

### 7. Verify Deployment

```bash
curl https://tm.yourdomain.com/healthz
# Expected response: "Service ready."
```

### 8. Access the Application

Navigate to `https://tm.yourdomain.com` and complete the initial Memos setup.

## Workflow Execution Order

**Fresh Deployment**:

1. `create-backend.yaml` - Setup Terraform backend (S3, DynamoDB)
2. `terraform-apply.yaml` - Deploy infrastructure (includes OIDC setup)
3. `docker-build.yaml` - Build and deploy application

**Application Updates**:

- `docker-build.yaml` - Build and deploy new app version
  - Builds multi-stage Docker image (frontend + backend)
  - Pushes to ECR with SHA-based tags
  - Updates ECS task definition and service

**Application Cleanup**:

- `docker-destroy.yaml` - Delete Docker images and scale down service
  - Deletes specified image from ECR
  - Scales ECS service to 0 tasks
  - Preserves DNS records (managed by Terraform)

**Infrastructure Updates**:

- `terraform-plan.yaml` - Preview changes
- `terraform-apply.yaml` - Apply changes (includes state refresh and task definition sync)
- `terraform-validate.yaml` - Validate Terraform configuration

**Infrastructure Teardown**:

- `terraform-destroy.yaml` - Destroy all infrastructure
- `destroy-backend.yaml` - Destroy Terraform backend (after infrastructure)

## Screenshots

### Successful Deployment

![Application Running on HTTPS](docs/screenshots/tm.tomakady.com%20https.png)

The application is successfully running at `https://tm.tomakady.com` with HTTPS enabled and custom domain configured.

## Local Scripts

The `scripts/` directory contains bash scripts for local operations:

- **Backend Management**: `create-backend.sh`, `destroy-backend.sh`
- **Terraform Operations**: `terraform-apply.sh`, `terraform-destroy.sh`
- **Docker Operations**: `docker-build.sh`, `docker-destroy.sh`

All scripts support environment variable configuration and include safety checks. Execute them in the order described in the "Workflow Execution Order" section above.

## Key Technical Details

### Docker Build Process

The Dockerfile uses a multi-stage build:

1. **Frontend Builder**: Node.js 20 with pnpm
   - Installs dependencies with `pnpm install --frozen-lockfile`
   - Builds frontend with `pnpm run release`
   - Outputs to `server/router/frontend/dist`

2. **Backend Builder**: Go 1.23+ with automatic toolchain
   - Uses `GOTOOLCHAIN=auto` to auto-download required Go version
   - Builds Go binary: `go build -o memos ./bin/memos/main.go`
   - Copies frontend assets from frontend-builder stage

3. **Runtime**: Alpine-based minimal image
   - Contains only the compiled binary and frontend assets

### State Management

- Terraform state stored in S3 with DynamoDB locking
- Automatic state refresh before plan/apply
- Task definition state drift protection (handles external updates from docker-build workflow)

## Useful Links

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Memos Documentation](https://www.usememos.com/docs)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

---

**Built as part of the CoderCo ECS Project**

👤 **Author**: Tomasz Kadyszewski | United Kingdom | DevOps Engineer
