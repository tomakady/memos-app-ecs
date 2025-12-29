#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-eu-west-2}"
S3_BUCKET="${S3_BUCKET:-memos-terraform-state}"
DYNAMODB_TABLE="${DYNAMODB_TABLE:-memos-terraform-locks}"
ECR_REPOSITORY="${ECR_REPOSITORY:-memos-dev}"

[ "${1-}" = "destroy" ] || {
	echo "Usage: $0 destroy" >&2
	exit 1
}

aws ecr delete-repository --repository-name "$ECR_REPOSITORY" --force --region "$AWS_REGION" || true
aws s3 rb s3://"$S3_BUCKET" --force || true
aws dynamodb delete-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" || true
