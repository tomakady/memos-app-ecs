#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../infra"
terraform init -reconfigure
terraform apply -auto-approve
