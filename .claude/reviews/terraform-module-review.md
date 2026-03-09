# Terraform Module Review: modules/openclaw

Last Updated: 2026-03-08

---

## Executive Summary

The `modules/openclaw` module deploys an OpenClaw AI Agent Gateway on AWS using an ALB-backed
EC2 instance with Cognito authentication, Bedrock integration, Secrets Manager for API keys,
and Ollama for local model inference. The module is well-structured with logical file
organization, good use of InfraHouse registry modules (`website-pod`, `cloud-init`), and
proper IAM policy documents. However, there are several critical security issues, important
improvements, and coding standard deviations that should be addressed before production use.

**Critical findings**: 4 | **Security concerns**: 5 | **Important improvements**: 7 | **Minor**: 6

---

## Critical Issues (must fix before use)

### C1. Secrets Manager secret lacks encryption with KMS key

**File**: `iam.tf:52-55`

```hcl
resource "aws_secretsmanager_secret" "api_keys" {
  name_prefix = "openclaw/api-keys-"
  description = "LLM provider API keys for OpenClaw (Anthropic, OpenAI, etc.)."
}
```

The secret is created without specifying a KMS key. While AWS uses a default key, the
InfraHouse coding standard recommends using the `infrahouse/secret/aws` module for secrets
management, which provides proper access control and auditing. At minimum, this should have
explicit encryption configuration.

**Recommendation**: Use the `infrahouse/secret/aws` module or at least add `kms_key_id` and
a `readers` list pattern per InfraHouse standards.

### C2. Shell script pipes untrusted URL content directly to bash

**File**: `setup-openclaw.sh.tftpl:35`

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

This is a classic supply chain attack vector. If ollama.com is compromised, arbitrary code
runs as root on the instance. The same pattern exists for Node.js:

**File**: `main.tf:103`
```
"curl -fsSL https://deb.nodesource.com/setup_22.x | bash -",
```

**Recommendation**: Pin to known-good checksums, use a private artifact mirror, or install
from package repositories. At minimum, document this as an accepted risk.

### C3. Cognito user passwords stored in Terraform state

**File**: `cognito.tf:72-80`

```hcl
resource "random_password" "users" {
  for_each = { for user in var.cognito_users : user.email => user }
  length   = 13
  ...
}
```

The `random_password` resource stores the password in plaintext in the Terraform state file.
Combined with `temporary_password` on `aws_cognito_user`, these secrets persist in state.
Since `admin_create_user_config.allow_admin_create_user_only = true`, the user will be forced
to change the password on first login, but the temporary password is still visible in state.

**Recommendation**: Accept this as a known tradeoff and document it, or consider using
Cognito's built-in invitation email flow instead of managing passwords in Terraform. If
keeping this pattern, the `random_password` length of 13 is fine, but the password policy
requires 12 minimum, so there is minimal margin.

### C4. No `required_version` for Terraform in `terraform.tf`

**File**: `terraform.tf`

The `terraform {}` block does not specify a `required_version` constraint. This means any
Terraform version could be used, which may cause compatibility issues. The repo uses
Terraform 1.14.3 (per `.terraform-version`), and child modules should declare their
minimum version.

**Recommendation**: Add a `required_version` constraint:
```hcl
terraform {
  required_version = ">= 1.5"
  ...
}
```

---

## Security Concerns

### S1. Bedrock `ListFoundationModels` and `GetFoundationModel` use wildcard resource

**File**: `iam.tf:26-37`

```hcl
dynamic "statement" {
  for_each = length(var.bedrock_model_ids) > 0 ? [1] : []
  content {
    sid    = "BedrockList"
    effect = "Allow"
    actions = [
      "bedrock:ListFoundationModels",
      "bedrock:GetFoundationModel",
    ]
    resources = ["*"]
  }
}
```

While `bedrock:ListFoundationModels` does require `*` as the resource (it is an
account-level action), this should be documented with a comment explaining why `*` is
necessary. The coding standard says to avoid `*` actions/resources, and this is a valid
exception that should be explicitly noted.

**Recommendation**: Add a comment explaining the AWS API constraint:
```hcl
# bedrock:List/GetFoundationModels are account-level actions that require resource = "*"
resources = ["*"]
```

### S2. ALB allows `0.0.0.0/0` by default

**File**: `variables.tf:63-70`

```hcl
variable "allowed_cidrs" {
  ...
  default     = ["0.0.0.0/0"]
}
```

The default allows public access to the ALB. While Cognito authentication protects the
application (and the description documents this), the coding standard says "Avoid `0.0.0.0/0`
for ingress rules (except specific cases like public ALBs)." This is a public ALB case, but
the default being wide open is risky. If someone deploys this module without configuring
Cognito users or if there is a Cognito misconfiguration, the backend is exposed.

**Recommendation**: This is acceptable for the intended use case (Cognito-protected public
app), but consider whether the module should have no default here, forcing the deployer to
make an explicit choice. Alternatively, add a validation block.

### S3. Gateway token generated at boot time, not managed by Terraform

**File**: `setup-openclaw.sh.tftpl:21`

```bash
GATEWAY_TOKEN=$(openssl rand -hex 32)
```

The gateway token is generated during instance bootstrap. This means:
1. The token is not tracked/auditable
2. It changes on every instance replacement
3. There is no way to rotate it without replacing the instance

**Recommendation**: Consider generating the token in Terraform (via `random_password`) and
storing it in Secrets Manager, then reading it in the setup script. This provides
auditability and persistence across instance replacements.

### S4. `ih-secrets` dependency not declared

**File**: `setup-openclaw.sh.tftpl:7`

```bash
SECRET_JSON=$(ih-secrets get "${secret_name}")
```

The script depends on `ih-secrets` being available on the AMI. If the AMI does not include
this tool, the script will fail silently or crash. There is no error handling around this
call.

**Recommendation**: Add error handling or a check for the `ih-secrets` binary. The InfraHouse
pro AMI likely includes it, but it should be documented as a prerequisite.

### S5. Systemd service `ProtectHome=read-only` may be too permissive

**File**: `openclaw.service:19`

The service has `ProtectHome=read-only` which allows the openclaw user to read all home
directories. Consider using `ProtectHome=tmpfs` combined with `BindPaths` or
`ReadWritePaths` for just `/home/openclaw`.

---

## Important Improvements (should fix)

### I1. Missing `environment` tag propagation to all resources

The `module.openclaw_pod` receives an `environment` tag implicitly through the `environment`
variable, and the `tags` block only includes `service = "openclaw"`. However, the Cognito
resources, Secrets Manager secret, and other resources created directly in this module do not
have tags at all.

**Files**: `cognito.tf`, `iam.tf`

Per the coding standard: "Require environment tag from user" and resources should have
provenance tags (`created_by`, `created_by_module`).

**Recommendation**: Add tags to all resources:
```hcl
resource "aws_secretsmanager_secret" "api_keys" {
  name_prefix = "openclaw/api-keys-"
  description = "LLM provider API keys for OpenClaw (Anthropic, OpenAI, etc.)."
  tags = {
    environment = var.environment
    service     = "openclaw"
  }
}
```

### I2. Cognito user pool lacks tags and advanced security features

**File**: `cognito.tf:5-41`

The `aws_cognito_user_pool` resource has no tags and does not enable:
- `user_pool_add_ons { advanced_security_mode = "ENFORCED" }` for detecting compromised
  credentials
- MFA configuration
- Deletion protection

For a production deployment protecting access to an AI agent gateway, MFA should be
considered.

**Recommendation**: Add at minimum:
```hcl
resource "aws_cognito_user_pool" "this" {
  name                     = "openclaw"
  deletion_protection      = "ACTIVE"

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = true
  }
  ...
}
```

### I3. Hardcoded service name "openclaw" throughout

Multiple files hardcode `"openclaw"` as the service name, key pair name, Cognito pool name,
etc. While this is a purpose-built module, making the service name configurable via a variable
(defaulting to `"openclaw"`) would improve reusability.

**Files**: `main.tf:27`, `main.tf:12`, `cognito.tf:6`, `cognito.tf:44`, `cognito.tf:49`

**Recommendation**: Add a `service_name` variable with default `"openclaw"` and use it
throughout.

### I4. No CloudWatch log retention or monitoring configuration

The module does not configure CloudWatch Logs or alarms. The systemd service logs to
journald (`StandardOutput=journal`), but there is no CloudWatch agent or log forwarding
configured. The coding standard requires 365-day log retention.

**Recommendation**: Configure the `website-pod` module's logging capabilities or add a
CloudWatch log group with appropriate retention. The `cloud-init` module may support this.

### I5. Ollama model `glm-4.7-flash` is hardcoded

**File**: `setup-openclaw.sh.tftpl:38`

```bash
su - openclaw -c 'nohup ollama pull glm-4.7-flash > /dev/null 2>&1 &' || true
```

The Ollama model name is hardcoded and pulled in the background without logging. This should
be a variable.

**Recommendation**: Add a variable for the default Ollama model:
```hcl
variable "ollama_default_model" {
  type        = string
  description = "Default Ollama model to pull on instance bootstrap."
  default     = "glm-4.7-flash"
}
```

### I6. Setup script discards Ollama pull output

**File**: `setup-openclaw.sh.tftpl:38`

```bash
su - openclaw -c 'nohup ollama pull glm-4.7-flash > /dev/null 2>&1 &' || true
```

Both stdout and stderr are redirected to `/dev/null`, making it impossible to troubleshoot
if the model pull fails. The `|| true` also swallows errors.

**Recommendation**: Log to a file instead:
```bash
su - openclaw -c 'nohup ollama pull glm-4.7-flash > /var/log/ollama-pull.log 2>&1 &' || true
```

### I7. `REGION_PLACEHOLDER` / `GATEWAY_TOKEN_PLACEHOLDER` pattern is fragile

**File**: `setup-openclaw.sh.tftpl:28-31`

```bash
sed -i "s/GATEWAY_TOKEN_PLACEHOLDER/$GATEWAY_TOKEN/g" ...
sed -i "s/REGION_PLACEHOLDER/${region}/g" ...
```

Using `sed` to replace placeholders in a JSON file is fragile. If the token or region
contains characters that `sed` interprets specially (e.g., `/`, `&`), the substitution will
break.

**Recommendation**: Use `jq` (already installed as a package) to modify the JSON
programmatically:
```bash
jq --arg token "$GATEWAY_TOKEN" '.gateway.auth.token = $token' ...
```

---

## Minor Suggestions (nice to have)

### M1. `.gitignore` contains entries irrelevant to a local module

**File**: `.gitignore`

Entries like `/modules/jumphost/update_dns.zip` and `/docs/_build/` appear to be copied from
the root repo's `.gitignore` and are not relevant to this module. The staged version (14
lines) is cleaner than the original diff version (38 lines), which is good.

### M2. Cognito session timeout could be a variable

**File**: `cognito.tf:118`

```hcl
session_timeout = 86400
```

The 24-hour session timeout is hardcoded. This could be a variable with the same default.

### M3. `password_policy.minimum_length` should match `random_password.length` with margin

**File**: `cognito.tf:11` vs `cognito.tf:73`

The password policy requires 12 characters minimum, and `random_password` generates 13.
While this works, a larger margin (e.g., 16 characters) would be safer and is a better
practice for temporary passwords.

### M4. Consider adding `prevent_destroy` lifecycle to Cognito user pool

The Cognito user pool contains user accounts. Accidental destruction would lock out all
users. Consider:
```hcl
lifecycle {
  prevent_destroy = true
}
```

### M5. The `random` provider may not be needed

**File**: `terraform.tf:12-14`

The `random` provider is declared in `required_providers` and used for `random_password` in
`cognito.tf`. This is correct. However, the version constraint `>= 3.0` is a range, not
an exact pin. For consistency with InfraHouse standards on external module versions,
consider whether this matters for provider version constraints (provider version ranges are
generally acceptable, unlike module versions).

### M6. AMI owner account ID is hardcoded

**File**: `datasources.tf:31`

```hcl
owners = ["303467602807"] # InfraHouse
```

This is the CI/CD account ID. While it is correct for InfraHouse, making this a variable
would improve reusability. However, since this is a local module in the control repo, the
hardcoding is acceptable here.

---

## Missing Features

### F1. No README.md

The module has no `README.md`. Per InfraHouse coding standards, modules should have a
README with terraform-docs markers. Even local modules in a control repo benefit from
documentation.

### F2. No examples directory

No `examples/` directory is provided. While this is a local module in a control repo (not
published to a registry), having a usage example would help other team members.

### F3. No health check or self-healing beyond ASG

The module relies on ALB health checks to detect failures. If OpenClaw starts but responds
incorrectly, or if the Ollama service fails, there is no automated remediation. Consider
adding a more sophisticated health check endpoint.

### F4. No backup/persistence strategy

OpenClaw configuration and agent data live on the instance. If the instance is replaced (ASG
termination, AZ failure), all data is lost. Consider adding an EBS volume or EFS mount for
persistent data, or document this as a known limitation.

### F5. No output for Cognito user pool domain URL

The module does not output the Cognito hosted UI URL, which could be useful for debugging
authentication issues:
```hcl
output "cognito_domain_url" {
  description = "Cognito hosted UI domain URL."
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.this.name}.amazoncognito.com"
}
```

---

## Testing Recommendations

### T1. No tests exist

This is a local module in a control repo, and the CLAUDE.md states "There is no test suite."
However, for a module of this complexity, at minimum:

1. Run `terraform validate` on the module
2. Run `terraform plan` with a mock `.tfvars` to catch configuration errors
3. Consider extracting this into a standalone published module with proper integration tests

### T2. Validate with `terraform fmt`

Ensure the module passes `terraform fmt -check -recursive` before merging.

---

## Code Standards Compliance Summary

| Standard | Status | Notes |
|----------|--------|-------|
| snake_case naming | PASS | All resources, variables, locals use snake_case |
| Variable descriptions | PASS | All variables have descriptions |
| Variable types | PASS | All variables have explicit types |
| Variable validation | PASS | Good validation on environment, subnets, volume size |
| HEREDOC for long descriptions | PASS | Used appropriately |
| aws_iam_policy_document data source | PASS | Used correctly in iam.tf |
| Sensitive outputs | PASS | `ssh_private_key` is marked sensitive |
| File organization | PASS | Logical split across files |
| 120-char line length | PASS | No obvious violations |
| Exact module version pins | PASS | website-pod 5.17.0, cloud-init 2.2.3 |
| InfraHouse registry | PASS | Both modules from registry.infrahouse.com |
| Resource tagging | FAIL | Missing tags on Cognito, Secrets Manager resources |
| Secrets management pattern | FAIL | Should use infrahouse/secret/aws module |
| Log retention 365 days | FAIL | No CloudWatch logs configured |
| required_version | FAIL | Missing from terraform.tf |

---

## Next Steps

1. **Immediate** (Critical):
   - Add `required_version` to `terraform.tf`
   - Address the Secrets Manager encryption/module usage
   - Document the `curl | bash` supply chain risk

2. **Before production** (Important):
   - Add tags to all resources (Cognito, Secrets Manager)
   - Add Cognito MFA and advanced security
   - Replace `sed` placeholder pattern with `jq`
   - Make Ollama model configurable

3. **Future improvements** (Nice to have):
   - Add README.md
   - Consider data persistence strategy
   - Extract into a standalone published module
   - Add CloudWatch logging and monitoring