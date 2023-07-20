resource "aws_cloudfront_distribution" "infrahouse-release" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [local.domain_name]

  origin {
    domain_name = aws_s3_bucket_website_configuration.infrahouse-release.website_endpoint
    origin_id   = local.ih_release_origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.ih_release_origin_id
    viewer_protocol_policy = "https-only"
    allowed_methods = [
      "GET", "HEAD"
    ]
    cached_methods = [
      "GET", "HEAD"
    ]
    cache_policy_id = aws_cloudfront_cache_policy.default.id
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.release_infrahouse.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations = [
        "RU",
        "CN",
        "IR"
      ]
    }
  }

}

resource "aws_cloudfront_cache_policy" "default" {
  name        = "release_infrahouse_default"
  min_ttl     = 60
  default_ttl = 300
  max_ttl     = 600

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }

}
