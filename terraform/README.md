# Terraform

Modular Terraform for the dev environment of the microservice.

## Layout

```
terraform/
├── bootstrap/          # one-time: creates S3 state bucket + DynamoDB lock table (local state)
├── modules/
│   ├── vpc/            # VPC, public+private subnets, IGW, single NAT
│   ├── eks/            # EKS cluster + managed node group + OIDC provider for IRSA
│   ├── ecr/            # ECR repo with lifecycle (keep last 10) + scan-on-push
│   └── iam/            # GitHub Actions OIDC IAM role + ECR/EKS permissions
└── envs/
    └── dev/            # composes all modules; backend.tf points at S3 state
```

## First-time setup

1. Configure AWS admin credentials: `aws configure`.
2. Copy `envs/dev/terraform.tfvars.example` to `envs/dev/terraform.tfvars` and fill in:
   - `github_owner` (your GitHub org/user)
   - `github_repo`  (the repo name)
3. From the repo root run `./scripts/bootstrap.sh`. This will:
   - apply `bootstrap/` to create the S3 state bucket and DynamoDB lock table (local state)
   - apply `envs/dev/` to provision VPC, EKS, ECR, and the GitHub Actions OIDC role
   - print the values to paste into GitHub repo Secrets/Variables.

## Day-2 changes

```
cd terraform/envs/dev
terraform plan
terraform apply
```

## Tear down

```
cd terraform/envs/dev && terraform destroy
cd ../../bootstrap && terraform destroy   # only if you also want to remove state backend
```

Note: ECR images and S3 versions may need manual cleanup before destroy succeeds.

## Cost (rough, dev idle)

~\$75/month: EKS control plane (~\$73) + 2x t3.medium (~\$30 — within free tier on a new account otherwise) + 1x NAT gateway (~\$32) + minor ECR/EBS.
