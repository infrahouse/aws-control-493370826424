resource "aws_secretsmanager_secret" "github_token" {
  name                    = "GITHUB_TOKEN"
  description             = "GitHub token with manage_runners:org permissions. Needed to register self-hosted runners."
  recovery_window_in_days = 0
}
