# OpenClaw Module

Deploys [OpenClaw](https://github.com/openclaw) AI agent gateway on AWS
using EC2 behind an ALB with Cognito authentication.

## Features

- ALB with ACM certificate and Cognito-based authentication
- Multiple LLM provider support: AWS Bedrock, Anthropic API, OpenAI API, Ollama (local)
- API keys stored in Secrets Manager (KMS-encrypted via `infrahouse/secret/aws`)
- Ollama installed for local model inference
- CloudWatch logging with 365-day retention (ISO27001/SOC2)
- Cognito user pool with optional MFA and advanced security

## Quick Start

```hcl
module "openclaw" {
  source = "./modules/openclaw"

  environment        = "production"
  zone_id            = aws_route53_zone.example.zone_id
  alb_subnet_ids     = module.network.subnet_public_ids
  backend_subnet_ids = module.network.subnet_private_ids

  cognito_users = [
    {
      email     = "admin@example.com"
      full_name = "Admin User"
    },
  ]
}
```

After applying, populate the API keys secret:

```bash
aws secretsmanager put-secret-value \
  --secret-id <module.openclaw.secret_arn> \
  --secret-string '{"ANTHROPIC_API_KEY":"sk-...", "OPENAI_API_KEY":"sk-..."}'
```

## LLM Provider Options

| Provider | Configuration |
|----------|--------------|
| **Bedrock** | Set `enable_bedrock = true` (default). Uses IAM, no API keys. |
| **Anthropic API** | Add `ANTHROPIC_API_KEY` to the Secrets Manager secret. |
| **OpenAI API** | Add `OPENAI_API_KEY` to the Secrets Manager secret. |
| **Ollama** | Always available. Set `ollama_default_model` to pre-pull a model. |

## Instance Sizing for Ollama Models

The `instance_type` should match the Ollama model you plan to run. Ollama
models are loaded entirely into RAM; if the model exceeds available memory the
instance will swap heavily and become unresponsive.

| Ollama model | Params | RAM needed | Recommended instance | Monthly cost |
|-------------|--------|-----------|---------------------|-------------|
| qwen2.5:1.5b, phi3:mini, gemma2:2b | 1-3B | 2-4 GB | t3.large (8 GB) | ~$60 |
| llama3.1:8b, mistral:7b, qwen2.5:7b | 7-8B | 5-8 GB | t3.xlarge (16 GB) | ~$121 |
| qwen2.5:14b, llama2:13b | 13-14B | 10-16 GB | r6i.xlarge (32 GB) | ~$181 |
| codellama:34b, deepseek-coder:33b | 30-34B | 20-36 GB | r6i.2xlarge (64 GB) | ~$363 |
| llama3.1:70b | 70B | 40-48 GB | r6i.4xlarge (128 GB) | ~$725 |

The default `t3.large` (8 GB) is sufficient when using only cloud LLM providers
(Bedrock, Anthropic API, OpenAI API) with a small local model for
experimentation. If you don't need local models, set `ollama_default_model = ""`
to skip the model pull entirely.

Example with a larger model:

```hcl
module "openclaw" {
  source = "./modules/openclaw"
  # ...
  instance_type       = "r6i.xlarge"    # 32 GB RAM
  ollama_default_model = "qwen2.5:14b"  # ~10 GB
}
```

## Prerequisites

- InfraHouse Pro AMI (Ubuntu Noble) with CloudWatch agent
- `infrahouse-toolkit` (installed via cloud-init packages)
- VPC with public subnets (ALB) and at least one backend subnet

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
