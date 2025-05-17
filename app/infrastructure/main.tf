provider "aws" {
  # Only set access_key/secret_key for LocalStack
  access_key = var.localstack_enabled ? "test" : null
  secret_key = var.localstack_enabled ? "test" : null

  region = var.region

  # LocalStack-specific settings
  s3_use_path_style           = var.localstack_enabled ? true : false
  skip_credentials_validation = var.localstack_enabled ? true : false
  skip_metadata_api_check     = var.localstack_enabled ? true : false
  skip_requesting_account_id  = var.localstack_enabled ? true : false

  # Dynamically set endpoints for LocalStack
  dynamic "endpoints" {
    for_each = var.localstack_enabled ? [1] : []
    content {
      iam         = "http://iam.localhost.localstack.cloud:4566"
      ec2         = "http://ec2.localhost.localstack.cloud:4566"
      s3          = "http://s3.localhost.localstack.cloud:4566"
      sqs         = "http://sqs.localhost.localstack.cloud:4566"
      lambda      = "http://lambda.localhost.localstack.cloud:4566"
      eventbridge = "http://eventbridge.localhost.localstack.cloud:4566"
      dynamodb    = "http://dynamodb.localhost.localstack.cloud:4566"
      apigateway  = "http://apigateway.localhost.localstack.cloud:4566"
      logs        = "http://logs.localhost.localstack.cloud:4566"
    }
  }
}

# S3 bucket to test LocalStack
resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket-${var.naming_suffix}"

  tags = {
    Name        = "Test Dev Bucket"
    Environment = "LocalStack"
  }
}