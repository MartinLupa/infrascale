variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-2"
}

variable "localstack_enabled" {
  description = "Enable LocalStack for local testing"
  type        = bool
  default     = false
}