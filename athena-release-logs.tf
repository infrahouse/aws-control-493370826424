module "athena_results_bucket" {
  providers = {
    aws = aws.aws-493370826424-uw1
  }
  source        = "registry.infrahouse.com/infrahouse/s3-bucket/aws"
  version       = "0.3.1"
  bucket_name   = "infrahouse-athena-results-493370826424"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results" {
  provider = aws.aws-493370826424-uw1
  bucket   = module.athena_results_bucket.bucket_name

  rule {
    id     = "expire-query-results"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

resource "aws_athena_workgroup" "release_logs" {
  provider = aws.aws-493370826424-uw1
  name     = "release-logs"

  configuration {
    result_configuration {
      output_location = "s3://${module.athena_results_bucket.bucket_name}/release-logs/"
    }
    enforce_workgroup_configuration = true
  }
}

resource "aws_glue_catalog_database" "release_logs" {
  provider = aws.aws-493370826424-uw1
  name     = "release_logs"
}

resource "aws_glue_catalog_table" "cloudfront_logs" {
  provider      = aws.aws-493370826424-uw1
  for_each      = toset(local.supported_codenames)
  database_name = aws_glue_catalog_database.release_logs.name
  name          = "cloudfront_${each.value}"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = "2"
    EXTERNAL                 = "TRUE"
  }

  storage_descriptor {
    location      = "s3://infrahouse-release-${each.value}-logs/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim"          = "\t"
        "serialization.format" = "\t"
      }
    }

    columns {
      name = "log_date"
      type = "date"
    }
    columns {
      name = "log_time"
      type = "string"
    }
    columns {
      name = "x_edge_location"
      type = "string"
    }
    columns {
      name = "sc_bytes"
      type = "bigint"
    }
    columns {
      name = "c_ip"
      type = "string"
    }
    columns {
      name = "cs_method"
      type = "string"
    }
    columns {
      name = "cs_host"
      type = "string"
    }
    columns {
      name = "cs_uri_stem"
      type = "string"
    }
    columns {
      name = "sc_status"
      type = "int"
    }
    columns {
      name = "cs_referer"
      type = "string"
    }
    columns {
      name = "cs_user_agent"
      type = "string"
    }
    columns {
      name = "cs_uri_query"
      type = "string"
    }
    columns {
      name = "cs_cookie"
      type = "string"
    }
    columns {
      name = "x_edge_result_type"
      type = "string"
    }
    columns {
      name = "x_edge_request_id"
      type = "string"
    }
    columns {
      name = "x_host_header"
      type = "string"
    }
    columns {
      name = "cs_protocol"
      type = "string"
    }
    columns {
      name = "cs_bytes"
      type = "bigint"
    }
    columns {
      name = "time_taken"
      type = "float"
    }
    columns {
      name = "x_forwarded_for"
      type = "string"
    }
    columns {
      name = "ssl_protocol"
      type = "string"
    }
    columns {
      name = "ssl_cipher"
      type = "string"
    }
    columns {
      name = "x_edge_response_result_type"
      type = "string"
    }
    columns {
      name = "cs_protocol_version"
      type = "string"
    }
    columns {
      name = "fle_status"
      type = "string"
    }
    columns {
      name = "fle_encrypted_fields"
      type = "int"
    }
    columns {
      name = "c_port"
      type = "int"
    }
    columns {
      name = "time_to_first_byte"
      type = "float"
    }
    columns {
      name = "x_edge_detailed_result_type"
      type = "string"
    }
    columns {
      name = "sc_content_type"
      type = "string"
    }
    columns {
      name = "sc_content_len"
      type = "bigint"
    }
    columns {
      name = "sc_range_start"
      type = "bigint"
    }
    columns {
      name = "sc_range_end"
      type = "bigint"
    }
  }
}

resource "aws_athena_named_query" "top_packages" {
  provider    = aws.aws-493370826424-uw1
  for_each    = toset(local.supported_codenames)
  name        = "top-packages-${each.value}"
  workgroup   = aws_athena_workgroup.release_logs.name
  database    = aws_glue_catalog_database.release_logs.name
  description = "Top 50 most downloaded packages from release-${each.value}"
  query       = <<-EOQ
    SELECT
      cs_uri_stem,
      COUNT(*) AS downloads,
      COUNT(DISTINCT c_ip) AS unique_ips,
      SUM(sc_bytes) / 1048576 AS total_mb
    FROM cloudfront_${each.value}
    WHERE sc_status = 200
      AND cs_uri_stem LIKE '%.deb'
    GROUP BY cs_uri_stem
    ORDER BY downloads DESC
    LIMIT 50
  EOQ
}

resource "aws_athena_named_query" "unique_users" {
  provider    = aws.aws-493370826424-uw1
  for_each    = toset(local.supported_codenames)
  name        = "unique-users-${each.value}"
  workgroup   = aws_athena_workgroup.release_logs.name
  database    = aws_glue_catalog_database.release_logs.name
  description = "Unique IPs and user agents accessing release-${each.value}"
  query       = <<-EOQ
    SELECT
      c_ip,
      cs_user_agent,
      COUNT(*) AS requests,
      MIN(log_date) AS first_seen,
      MAX(log_date) AS last_seen
    FROM cloudfront_${each.value}
    WHERE sc_status = 200
      AND cs_uri_stem LIKE '%.deb'
    GROUP BY c_ip, cs_user_agent
    ORDER BY requests DESC
    LIMIT 100
  EOQ
}

resource "aws_athena_named_query" "downloads_over_time" {
  provider    = aws.aws-493370826424-uw1
  for_each    = toset(local.supported_codenames)
  name        = "downloads-over-time-${each.value}"
  workgroup   = aws_athena_workgroup.release_logs.name
  database    = aws_glue_catalog_database.release_logs.name
  description = "Daily download counts and traffic for release-${each.value}"
  query       = <<-EOQ
    SELECT
      log_date,
      COUNT(*) AS downloads,
      COUNT(DISTINCT c_ip) AS unique_ips,
      SUM(sc_bytes) / 1048576 AS total_mb
    FROM cloudfront_${each.value}
    WHERE sc_status = 200
      AND cs_uri_stem LIKE '%.deb'
    GROUP BY log_date
    ORDER BY log_date DESC
    LIMIT 90
  EOQ
}

resource "aws_athena_named_query" "status_codes" {
  provider    = aws.aws-493370826424-uw1
  for_each    = toset(local.supported_codenames)
  name        = "status-codes-${each.value}"
  workgroup   = aws_athena_workgroup.release_logs.name
  database    = aws_glue_catalog_database.release_logs.name
  description = "HTTP status code distribution for release-${each.value}"
  query       = <<-EOQ
    SELECT
      sc_status,
      x_edge_result_type,
      COUNT(*) AS requests,
      SUM(sc_bytes) / 1048576 AS total_mb
    FROM cloudfront_${each.value}
    GROUP BY sc_status, x_edge_result_type
    ORDER BY requests DESC
  EOQ
}

resource "aws_athena_named_query" "top_downloaders" {
  provider    = aws.aws-493370826424-uw1
  for_each    = toset(local.supported_codenames)
  name        = "top-downloaders-${each.value}"
  workgroup   = aws_athena_workgroup.release_logs.name
  database    = aws_glue_catalog_database.release_logs.name
  description = "Top 50 IPs by download volume from release-${each.value}"
  query       = <<-EOQ
    SELECT
      c_ip,
      COUNT(*) AS requests,
      COUNT(DISTINCT cs_uri_stem) AS unique_packages,
      SUM(sc_bytes) / 1048576 AS total_mb,
      MIN(log_date) AS first_seen,
      MAX(log_date) AS last_seen
    FROM cloudfront_${each.value}
    WHERE sc_status = 200
      AND cs_uri_stem LIKE '%.deb'
    GROUP BY c_ip
    ORDER BY total_mb DESC
    LIMIT 50
  EOQ
}