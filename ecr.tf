resource "aws_ecrpublic_repository" "infrahouse" {
  provider        = aws.aws-493370826424-ue1
  repository_name = "infrahouse"
  catalog_data {
    about_text        = "InfraHouse software distributed as docker images."
    architectures     = ["x86-64"]
    description       = "InfraHouse Public Docker Repository"
    logo_image_blob   = filebase64("${path.module}/files/infrahouse-logo.png")
    operating_systems = ["Linux"]
    usage_text        = "docker pull TBD"
  }
}

resource "aws_ecrpublic_repository" "openvpn-portal" {
  provider        = aws.aws-493370826424-ue1
  repository_name = "openvpn-portal"
  catalog_data {
    about_text        = "InfraHouse OpenVPN Portal"
    architectures     = ["x86-64"]
    description       = "InfraHouse OpenVPN Portal is a web based service that authenticates users and generates OpenVPN profiles."
    logo_image_blob   = filebase64("${path.module}/files/infrahouse-logo.png")
    operating_systems = ["Linux"]
    usage_text        = "For usage details, check out https://registry.terraform.io/modules/infrahouse/openvpn/aws/latest"
  }
}
