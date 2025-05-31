resource "aws_dynamodb_table" "teleport" {
  name             = "teleport-${random_string.suffix.result}"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "HashKey"
  range_key        = "FullPath"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  deletion_protection_enabled = !var.force_destroy

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "HashKey"
    type = "S" # String
  }

  attribute {
    name = "FullPath"
    type = "S" # String
  }
  ttl {
    attribute_name = "Expires"
    enabled        = true
  }
}
