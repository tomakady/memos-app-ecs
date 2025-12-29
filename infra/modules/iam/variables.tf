variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "enable_efs_access" {
  type    = bool
  default = true
}

variable "efs_arn" {
  type    = string
  default = ""
}

variable "enable_secrets_access" {
  type    = bool
  default = false
}

variable "secrets_arns" {
  type    = list(string)
  default = ["*"]
}

variable "enable_s3_access" {
  type    = bool
  default = false
}

variable "s3_bucket_arns" {
  type    = list(string)
  default = []
}

variable "enable_cloudwatch_logs" {
  type    = bool
  default = false
}

variable "enable_github_oidc" {
  type    = bool
  default = false
}

variable "github_repo" {
  type    = string
  default = ""
}

variable "terraform_state_bucket" {
  type    = string
  default = "memos-terraform-state"
}

variable "terraform_lock_table" {
  type    = string
  default = "memos-terraform-locks"
}

variable "ecr_repository_arns" {
  type    = list(string)
  default = []
}

variable "ecs_cluster_arns" {
  type    = list(string)
  default = []
}

variable "ecs_service_arns" {
  type    = list(string)
  default = []
}

variable "enable_ecs_exec" {
  type    = bool
  default = false
}

variable "enable_autoscaling" {
  type    = bool
  default = false
}
