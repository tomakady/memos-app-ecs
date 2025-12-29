# Project Configuration
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "memos"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

# GitHub Actions OIDC
variable "enable_github_oidc" {
  description = "Enable GitHub OIDC for GitHub Actions deployments"
  type        = bool
  default     = false
}

variable "github_repo" {
  description = "GitHub repository in format 'owner/repo' used for OIDC trust"
  type        = string
  default     = ""
}

variable "ecr_repository_arns" {
  description = "Optional list of ECR repository ARNs to scope GitHub Actions"
  type        = list(string)
  default     = []
}

variable "ecs_cluster_arns" {
  description = "Optional list of ECS cluster ARNs to scope GitHub Actions"
  type        = list(string)
  default     = []
}

variable "ecs_service_arns" {
  description = "Optional list of ECS service ARNs to scope GitHub Actions"
  type        = list(string)
  default     = []
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

# DNS and SSL
variable "domain_name" {
  type        = string
  description = "Root domain name"
  default     = "tomakady.com"
}

# Application Configuration
variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "memos"
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 5230
}

variable "health_check_path" {
  description = "Health check path for ALB"
  type        = string
  default     = "/"
}

# ECS Configuration
variable "task_cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "efs_mount_path" {
  description = "Container path where EFS will be mounted"
  type        = string
  default     = "/var/opt/memos"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ECR Configuration
variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "image_count_to_keep" {
  description = "Number of images to keep in ECR"
  type        = number
  default     = 10
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "memos-terraform-state"
}

variable "terraform_lock_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
  default     = "memos-terraform-locks"
}