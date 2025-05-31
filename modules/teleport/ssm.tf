resource "aws_ssm_document" "TeleportDiscoveryInstaller" {
  name            = "TeleportDiscoveryInstaller"
  document_type   = "Command"
  document_format = "YAML"

  content = templatefile(
    "${path.module}/templates/TeleportDiscoveryInstaller.yaml.tfpl",
    {
      teleport_host = local.cluster_name
    }
  )
}
