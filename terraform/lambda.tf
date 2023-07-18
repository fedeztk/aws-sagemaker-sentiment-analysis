resource "aws_lambda_function" "my_nlp_lambda_function" {
  function_name = "NLPLambda"
  s3_bucket = aws_s3_bucket.my_nlp_bucket.bucket
  s3_key    = aws_s3_object.lambda_triggering_sagemaker.key
  runtime = "python3.7"
  handler = "lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda_triggering_sagemaker.output_base64sha256
  role = aws_iam_role.nlp_application_role.arn
  
  environment {
    variables = {
      ENDPOINT_NAME = module.huggingface_sagemaker.sagemaker_endpoint.name
      TABLE_NAME = aws_dynamodb_table.nlp_data_table.name
    }
  }
}

# define role for lambda function for access to dynamodb and sagemaker
resource "aws_iam_role" "nlp_application_role" {
  name = "nlp_application_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "nlp_application_policy" {
  name = "nlp_application_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        Effect = "Allow",
        Resource = aws_dynamodb_table.nlp_data_table.arn
      },
      {
        Action = [
          "sagemaker:InvokeEndpoint"
        ],
        Effect = "Allow",
        Resource = module.huggingface_sagemaker.sagemaker_endpoint.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource : "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nlp_execution_policy_attachment" {
    role = aws_iam_role.nlp_application_role.name
    policy_arn = aws_iam_policy.nlp_application_policy.arn
}