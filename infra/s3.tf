output "s3_arn" {
  value       = aws_s3_bucket.s3_bucket.arn
  description = "The ARN of the S3 bucket"
}

#IMPORTANT add needed policy this is only example with PUBLIC ACCESS
data "aws_iam_policy_document" "s3_bucket" {
  statement {
    sid = "PublicReadAccess"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::s3_bucket/*"
    ]
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.s3_bucket_name
  policy = data.aws_iam_policy_document.s3_bucket.json
  versioning {
    enabled = true
  }
  force_destroy = "true"
}

