output "infrahouse_ns" {
  value = aws_route53_zone.infrahouse_com.name_servers
}

output "infrahouse_zone_id" {
  value = aws_route53_zone.infrahouse_com.id
}

output "infrahouse_zone_name" {
  value = aws_route53_zone.infrahouse_com.name
}
