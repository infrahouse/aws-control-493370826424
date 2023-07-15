output "infrahouse_ns" {
  value = aws_route53_zone.infrahouse_com.name_servers
}