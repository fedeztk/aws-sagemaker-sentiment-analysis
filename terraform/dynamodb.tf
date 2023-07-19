resource "aws_dynamodb_table" "nlp_data_table" {
  name             = var.dynamodb_table_name
  billing_mode     = "PROVISIONED"
  read_capacity    = 20
  write_capacity   = 20
  hash_key         = "id"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
  attribute {
    name = "id"
    type = "S"
  }
}