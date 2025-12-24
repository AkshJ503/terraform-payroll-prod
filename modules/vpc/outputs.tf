# Export values for other modules to use

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (for Load Balancer)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (for EC2 instances)"
  value       = aws_subnet.private[*].id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}