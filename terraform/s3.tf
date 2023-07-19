data "archive_file" "lambda_triggering_sagemaker" {
  type        = "zip"
  source_dir  = "../code/lambda" # provide the path to the lambda folder
  output_path = "lambda.zip"     # provide output path including the file format (e.g. lambda.zip) 
}


resource "aws_s3_bucket" "my_nlp_bucket" {
  bucket_prefix = "my-nlp-bucket-"
}

resource "aws_s3_bucket_ownership_controls" "my_nlp_bucket_ownership_controls" {
  bucket = aws_s3_bucket.my_nlp_bucket.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "my_nlp_bucket_acl" {
  bucket = aws_s3_bucket.my_nlp_bucket.bucket
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.my_nlp_bucket_ownership_controls
  ]
}


resource "aws_s3_object" "lambda_triggering_sagemaker" {
  bucket = aws_s3_bucket.my_nlp_bucket.id
  key    = "sagemaker_lambda.zip"
  source = data.archive_file.lambda_triggering_sagemaker.output_path
  etag   = filemd5(data.archive_file.lambda_triggering_sagemaker.output_path)
}