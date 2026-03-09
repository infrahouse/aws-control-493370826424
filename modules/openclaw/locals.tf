locals {
  zone_name = trimsuffix(data.aws_route53_zone.this.name, ".")
  # Build the FQDN from the first A record entry and the zone name.
  # "" → "infrahouse.com", "openclaw" → "openclaw.infrahouse.com"
  fqdn = (
    var.dns_a_records[0] == ""
    ? local.zone_name
    : "${var.dns_a_records[0]}.${local.zone_name}"
  )

  enable_bedrock = var.enable_bedrock

  # Default Bedrock models with us. inference profile prefix.
  # OpenClaw bug #5290: auto-discovery lists foundation model IDs
  # that don't work for on-demand invocation.
  default_bedrock_models = [
    {
      id            = "us.anthropic.claude-sonnet-4-6"
      name          = "Claude Sonnet 4.6"
      reasoning     = true
      input         = ["text", "image"]
      contextWindow = 200000
      maxTokens     = 8192
    },
    {
      id            = "us.anthropic.claude-haiku-4-5-20251001-v1:0"
      name          = "Claude Haiku 4.5"
      input         = ["text", "image"]
      contextWindow = 200000
      maxTokens     = 8192
    },
    {
      id            = "us.anthropic.claude-opus-4-6-v1"
      name          = "Claude Opus 4.6"
      reasoning     = true
      input         = ["text", "image"]
      contextWindow = 200000
      maxTokens     = 8192
    },
    {
      id            = "us.amazon.nova-pro-v1:0"
      name          = "Amazon Nova Pro"
      input         = ["text", "image"]
      contextWindow = 300000
      maxTokens     = 5120
    },
    {
      id            = "us.amazon.nova-lite-v1:0"
      name          = "Amazon Nova Lite"
      input         = ["text", "image"]
      contextWindow = 300000
      maxTokens     = 5120
    },
    {
      id            = "us.amazon.nova-micro-v1:0"
      name          = "Amazon Nova Micro"
      input         = ["text"]
      contextWindow = 128000
      maxTokens     = 5120
    },
  ]

  # Primary model depends on whether Bedrock is enabled
  primary_model = (
    local.enable_bedrock
    ? "amazon-bedrock/us.anthropic.claude-sonnet-4-6"
    : "anthropic/claude-sonnet-4-6-20250514"
  )

  # Model providers configured in openclaw.json
  model_providers = merge(
    local.enable_bedrock ? {
      "amazon-bedrock" = {
        baseUrl = "https://bedrock-runtime.${data.aws_region.this.name}.amazonaws.com"
        api     = "bedrock-converse-stream"
        auth    = "aws-sdk"
        # Explicit models with us. inference profile prefix.
        # OpenClaw bug #5290: auto-discovery only lists foundation model
        # IDs which don't work for on-demand invocation.
        models = concat(local.default_bedrock_models, var.extra_bedrock_models)
      }
    } : {},
    {
      anthropic = {
        baseUrl = "https://api.anthropic.com"
        models  = []
      }
      openai = {
        baseUrl = "https://api.openai.com/v1"
        models  = []
      }
      ollama = {
        baseUrl = "http://127.0.0.1:11434/v1"
        apiKey  = "ollama-local"
        api     = "openai-completions"
        models  = []
      }
    }
  )

  openclaw_config = {
    gateway = {
      mode = "local"
      port = 5173
      bind = "lan"
      auth = {
        mode = "trusted-proxy"
        trustedProxy = {
          userHeader = "x-amzn-oidc-identity"
        }
      }
      trustedProxies = [for s in data.aws_subnet.alb : s.cidr_block]
      controlUi = {
        allowedOrigins = ["https://${local.fqdn}"]
      }
    }
    agents = {
      defaults = {
        maxConcurrent = 4
        compaction    = { mode = "safeguard" }
        model = {
          primary = local.primary_model
        }
      }
    }
    models = {
      providers = local.model_providers
    }
  }
}
