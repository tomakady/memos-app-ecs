#!/usr/bin/env bash
set -euo pipefail

[ "${1-}" = "destroy" ] || { echo "Usage: $0 destroy" >&2; exit 1; }

cd "$(dirname "${BASH_SOURCE[0]}")/../infra"
terraform init -reconfigure
terraform destroy -auto-approve
