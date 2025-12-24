# ==============================================================================
# INPUT VARIABLES
# ==============================================================================
# WHY: Makes infrastructure reusable across environments (dev, staging, prod)
# INSTEAD OF: Hardcoding values everywhere
# ==============================================================================

variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  # Validation ensures only approved values are used
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (range of IP addresses)"
  type        = string
  default     = "10.0.0.0/16"  # Provides 65,536 IP addresses
}

variable "availability_zones" {
  description = "List of AZs for high availability (multi-datacenter deployment)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type (size of virtual machine)"
  type        = string
  default     = "t2.medium"  # 2 vCPU, 4GB RAM - good for small apps
}

variable "min_size" {
  description = "Minimum number of EC2 instances in Auto Scaling Group"
  type        = number
  default     = 2  # Always keep 2 running for high availability
}

variable "max_size" {
  description = "Maximum number of EC2 instances (scale up limit)"
  type        = number
  default     = 6  # Can scale up to 6 during high traffic
}

variable "desired_capacity" {
  description = "Initial number of instances to launch"
  type        = number
  default     = 2
}

variable "app_name" {
  description = "Application name used in resource naming"
  type        = string
  default     = "flexit-payroll"
}

variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate in AWS Certificate Manager (for HTTPS)"
  type        = string
  default     = ""  # Must be provided for prod
}