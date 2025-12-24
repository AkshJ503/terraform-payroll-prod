# ==============================================================================
# DATA SOURCE: Latest Amazon Linux 2 AMI
# ==============================================================================
# WHY: Always use the latest patched AMI (security updates)
# ==============================================================================

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==============================================================================
# LAUNCH TEMPLATE
# ==============================================================================
# WHY: Defines HOW to launch EC2 instances
# BENEFITS: Version control, easy updates, consistent configuration
# ==============================================================================

resource "aws_launch_template" "main" {
  name_prefix   = "${var.app_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  
  # Attach IAM role (for S3, DynamoDB access)
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  
  # Attach security group
  vpc_security_group_ids = [var.ec2_security_group_id]
  
  # User data script (runs on first boot)
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    DYNAMODB_TABLE = var.dynamodb_table_name
    S3_BUCKET      = var.s3_bucket_name
  }))
  
  # ==============================================================================
  # METADATA OPTIONS (IMDSv2)
  # ==============================================================================
  # WHY: Enhanced security for instance metadata
  # PREVENTS: SSRF attacks that try to steal IAM credentials
  # ==============================================================================
  
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Force IMDSv2
    http_put_response_hop_limit = 1
  }
  
  # ==============================================================================
  # MONITORING
  # ==============================================================================
  # Enable detailed monitoring (1-minute metrics vs 5-minute)
  # COST: Slightly more expensive, but better visibility
  # ==============================================================================
  
  monitoring {
    enabled = true
  }
  
  # ==============================================================================
  # BLOCK DEVICE MAPPING (Disk Configuration)
  # ==============================================================================
  
  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size           = 20  # GB
      volume_type           = "gp3"  # Latest generation SSD
      encrypted             = true
      delete_on_termination = true
      
      # GP3 allows you to set IOPS and throughput independently
      iops       = 3000
      throughput = 125  # MB/s
    }
  }
  
  # Tag instances created from this template
  tag_specifications {
    resource_type = "instance"
    
    tags = {
      Name = "${var.app_name}-instance"
    }
  }
  
  tag_specifications {
    resource_type = "volume"
    
    tags = {
      Name = "${var.app_name}-volume"
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
````
