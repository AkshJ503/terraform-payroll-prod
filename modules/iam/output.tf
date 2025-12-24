output "instance_profile_name" {
  description = "IAM instance profile to attach to EC2"
  value       = aws_iam_instance_profile.ec2.name
}

output "iam_role_arn" {
  value = aws_iam_role.ec2.arn
}