#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-eu-west-2}"
ECR_REPOSITORY="${ECR_REPOSITORY:-memos-dev}"
ECS_CLUSTER="${ECS_CLUSTER:-memos-dev-cluster}"
ECS_SERVICE="${ECS_SERVICE:-memos-dev-service}"
IMAGE_TAG="${IMAGE_TAG:-$(git rev-parse HEAD)}"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE="${REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

aws ecr create-repository --repository-name "$ECR_REPOSITORY" 2>/dev/null || true
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"

cd "$(dirname "${BASH_SOURCE[0]}")/../app"
docker build -t "$IMAGE" -t "${REGISTRY}/${ECR_REPOSITORY}:latest" .
docker push "$IMAGE"
docker push "${REGISTRY}/${ECR_REPOSITORY}:latest"
cd ..

TASK_DEF=$(aws ecs describe-task-definition --task-definition memos-dev)
NEW_TASK_DEF=$(echo "$TASK_DEF" | jq --arg IMAGE "$IMAGE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)')
REVISION=$(aws ecs register-task-definition --cli-input-json "$NEW_TASK_DEF" | jq -r '.taskDefinition.revision')

aws ecs update-service --cluster "$ECS_CLUSTER" --service "$ECS_SERVICE" --task-definition "memos-dev:$REVISION"
aws ecs wait services-stable --cluster "$ECS_CLUSTER" --service "$ECS_SERVICE"
