# Define the variables used in your configuration:

variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "your-region"
}

variable "s3_bucket_name" {
  description = "S3 bucket for Terraform state"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for state locking"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "my-eks-cluster"
}
