#!/usr/bin/env bash
set -euo pipefail

ECS_CLUSTER="${ECS_CLUSTER:-memos-dev-cluster}"
ECS_SERVICE="${ECS_SERVICE:-memos-dev-service}"

[ "${DESTROY_CONFIRM:-}" = "destroy" ] || { echo "Set DESTROY_CONFIRM=destroy" >&2; exit 1; }

aws ecs update-service --cluster "$ECS_CLUSTER" --service "$ECS_SERVICE" --desired-count 0
aws ecs wait services-stable --cluster "$ECS_CLUSTER" --service "$ECS_SERVICE"
