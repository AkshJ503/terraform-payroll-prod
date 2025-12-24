output "bucket_name" {
  value = aws_s3_bucket.payroll.id
}

output "bucket_arn" {
  value = aws_s3_bucket.payroll.arn
}

output "kms_key_arn" {
  value = aws_kms_key.s3.arn
}