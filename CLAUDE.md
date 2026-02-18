# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## First Steps

**Your first tool call in this repository MUST be reading .claude/CODING_STANDARD.md.
Do not read any other files, search, or take any actions until you have read it.**
This contains InfraHouse's comprehensive coding standards for Terraform, Python, and general formatting rules.

## CAUTION: This is a Production Environment

`terraform.tfvars` sets `environment = "production"`. All changes here affect live infrastructure.
Always run `make plan` and review the plan output before applying.

## What This Repository Is

This is the Terraform control repo for AWS account **493370826424**
(InfraHouse management account). It provisions and manages:

- **Networking**: VPC (`management`, CIDR 10.0.0.0/22) via `infrahouse/service-network/aws`,
  jumphost for private access
- **DNS**: Route53 zones for infrahouse.com, twindb.com, selfdrivedb.app, cicd.infrahouse.com
- **Terraform Module Registry**: Private registry at registry.infrahouse.com with 50+ modules
- **Debian Package Repos**: release-{focal,jammy,noble,oracular}.infrahouse.com
- **ECR Public Repos**: Container images under public.ecr.aws/infrahouse/
- **GitHub OIDC Roles**: IAM roles for GitHub Actions CI/CD across ~10 repositories
- **GitHub Backup Service**: EC2-based GitHub backup with Puppet configuration
- **Email/SES**: SMTP for twindb.com and infrahouse.com
- **Cloudcraft**: Scanner role for infrastructure visualization

## Multi-Account Architecture

| Account | Purpose |
|---------|---------|
| 493370826424 | Management (this repo's target) |
| 289256138624 | Terraform state storage (S3 + DynamoDB) |
| 303467602807 | CI/CD account |

All providers assume `ih-tf-aws-control-493370826424-admin` role. State is stored in
account 289256138624 via a state-manager role. The CI/CD account's state is read via
`data.terraform_remote_state.cicd` in `data_sources.tf` (used for cross-account references
like the cicd.infrahouse.com DNS zone).

## Provider Aliases

- **default / `aws-493370826424-uw1`**: us-west-1 (primary region)
- **`aws-493370826424-ue1`**: us-east-1 (ECR public repos, some global services)
- **`aws-303467602807-uw1`**: us-west-1, read-only to CI/CD account

ECR public resources must use the `aws-493370826424-ue1` provider (us-east-1 requirement).

## Common Commands

```bash
make bootstrap     # Install dev dependencies + git hooks
make lint          # yamllint + terraform fmt -check
make format        # terraform fmt -recursive
make plan          # terraform init + plan (outputs tf.plan)
make apply         # terraform apply tf.plan
```

The pre-commit hook runs `make lint`.

## Key Patterns

### GitHub OIDC Provider

`aws_iam_openid_connect_provider.tf` creates the GitHub OIDC identity provider via
`infrahouse/gh-identity-provider/aws` module. This is the foundation that enables all
GitHub Actions roles in this repo.

### Adding GitHub OIDC Role Permissions

GitHub Actions roles are created by the `infrahouse/github-role/aws` module via
`module.registry` in `registry-new.tf`. The role names are accessed as
`module.registry.registry_client_role_names["<repo-name>"]`, where `<repo-name>` matches
an entry from the `terraform_modules` list in `registry-clients.tf`
(e.g., `"terraform-aws-openvpn"`).

To add permissions to a repo's GitHub Actions role, create a file following this pattern
(see `aws_iam_role.ih-tf-terraform-aws-openvpn-github.tf` as an example):

```hcl
data "aws_iam_policy_document" "<name>-permissions" {
  statement {
    actions   = [...]
    resources = [...]
  }
}

resource "aws_iam_policy" "<name>-permissions" {
  provider = aws.aws-493370826424-uw1
  name     = "<name>-permissions"
  policy   = data.aws_iam_policy_document.<name>-permissions.json
}

resource "aws_iam_role_policy_attachment" "<name>" {
  provider   = aws.aws-493370826424-uw1
  policy_arn = aws_iam_policy.<name>-permissions.arn
  role       = module.registry.registry_client_role_names["<repo-name>"]
}
```

### Adding a Terraform Module to the Registry

Add the repository name to the `terraform_modules` list in `registry-clients.tf`.

### Adding an ECR Public Repository

Add to `ecr.tf` with provider `aws.aws-493370826424-ue1` (us-east-1 required for public ECR).

### Adding a Debian Release Repository Consumer

Add the role ARN to `bucket_admin_roles` and/or `signing_key_readers` in `release.infrahouse.com.tf`.

## File Organization

- `terraform.tf` / `providers.tf` / `variables.tf` / `locals.tf` / `outputs.tf` -- Core Terraform config
- `ecr.tf` -- ECR public repositories
- `registry-new.tf` -- Terraform module registry
- `registry-clients.tf` -- List of 50+ modules and their registry-client IAM roles
- `release.infrahouse.com.tf` -- Debian package repositories
- `aws_iam_role.*.tf` -- Per-repository GitHub Actions IAM permissions
- `infrahouse-github-backup.tf` -- GitHub backup service (EC2 + secrets)
- `route53.*.tf` / `twindb-*.tf` / `selfdrivedb.app.tf` -- DNS zones
- `service-network.tf` / `jumphost.tf` -- Networking
- `modules/` -- Local modules (infrahouse.com zone, cloudcraft)

## CI/CD

- **CI** (`terraform-CI.yml`): On PR -- lint, validate, plan, upload plan to S3, post plan comment
- **CD** (`terraform-CD.yml`): On merge to main -- download plan from S3, apply, cleanup
- **Vuln scanner** (`vuln-scanner-pr.yml`): OSV vulnerability scanning on PRs
- Plans are stored/retrieved using `ih-plan` from infrahouse-toolkit

## No Tests

This is a control repo, not a Terraform module. There is no test suite. Validation is
done through `make plan` (CI posts the plan as a PR comment for review) and `make apply`.

## Terraform Version

Pinned in `.terraform-version` (currently 1.14.3). CI reads this file to select the version.
