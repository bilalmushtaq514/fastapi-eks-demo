#!/usr/bin/env bash
# One-time bootstrap: creates Terraform state backend, then provisions dev infra.
#
# Prerequisites:
#   - AWS CLI configured with admin credentials (aws configure)
#   - terraform >= 1.6, kubectl, aws CLI installed
#   - terraform/envs/dev/terraform.tfvars created from terraform.tfvars.example
#
# Usage:
#   ./scripts/bootstrap.sh
#
# Re-running is safe: terraform apply is idempotent.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_BOOTSTRAP="${REPO_ROOT}/terraform/bootstrap"
TF_DEV="${REPO_ROOT}/terraform/envs/dev"

echo "==> Verifying prerequisites"
for cmd in terraform aws kubectl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "ERROR: AWS credentials are not configured. Run 'aws configure'." >&2
  exit 1
fi

if [ ! -f "${TF_DEV}/terraform.tfvars" ]; then
  echo "ERROR: ${TF_DEV}/terraform.tfvars not found." >&2
  echo "       Copy terraform.tfvars.example and fill in github_owner/github_repo." >&2
  exit 1
fi

echo
echo "==> [1/3] Creating Terraform state backend (S3 + DynamoDB)"
cd "${TF_BOOTSTRAP}"
terraform init -input=false
terraform apply -auto-approve -input=false

echo
echo "==> [2/3] Provisioning dev infra (VPC, EKS, ECR, GH OIDC role)"
cd "${TF_DEV}"
terraform init -input=false
terraform apply -auto-approve -input=false

echo
echo "==> [3/3] Captured outputs"
ROLE_ARN=$(terraform output -raw github_actions_role_arn)
ECR_URL=$(terraform output -raw ecr_repository_url)
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)

cat <<EOF

============================================================
Bootstrap complete. Configure these in your GitHub repo
(Settings -> Secrets and variables -> Actions):

Secrets:
  AWS_ROLE_ARN    = ${ROLE_ARN}
  API_KEY         = <any value you want injected into the app>

Variables:
  AWS_REGION      = ${REGION}
  ECR_REPOSITORY  = ${ECR_URL}
  EKS_CLUSTER_NAME = ${CLUSTER_NAME}

Then push to 'main' to trigger the CI/CD pipeline.

To configure kubectl locally:
  aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${REGION}
============================================================
EOF
