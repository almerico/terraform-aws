resource "aws_s3_bucket" "terraform_state" {
  bucket = var.tf-state-bucket
  versioning {
    enabled = true
  }
  force_destroy = "true"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}


