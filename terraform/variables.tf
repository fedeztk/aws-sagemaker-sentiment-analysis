variable "dynamodb_table_name" {
  type = string
  default = "nlp_data_table"
  description = "Name of the DynamoDB table"
}

variable "instance_type" {
  type = string
  default = "ml.t2.medium"
  description = "Instance type for the SageMaker endpoint"
}