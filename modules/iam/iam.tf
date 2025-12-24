# ==============================================================================
# IAM ROLE for EC2 Instances
# ==============================================================================
# WHY: Gives EC2 instances permissions to access AWS services
# BEST PRACTICE: Use IAM roles instead of embedding access keys in code
# ==============================================================================

resource "aws_iam_role" "ec2" {
  name_prefix = "${var.app_name}-ec2-role"
  
  # Trust policy: WHO can assume this role
  # Answer: EC2 service
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name = "${var.app_name}-ec2-role"
  }
}

# ==============================================================================
# S3 ACCESS POLICY
# ==============================================================================
# WHY: EC2 instances need to read/write payslip documents to S3
# PRINCIPLE: Least privilege - only access specific bucket
# ==============================================================================

resource "aws_iam_policy" "s3_access" {
  name_prefix = "${var.app_name}-s3-policy"
  description = "Allow EC2 to access payroll S3 bucket"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",       # Read files
          "s3:PutObject",       # Upload files
          "s3:DeleteObject",    # Delete files
          "s3:ListBucket"       # List files in bucket
        ]
        Resource = [
          "${var.s3_bucket_arn}",        # Bucket itself
          "${var.s3_bucket_arn}/*"       # All objects in bucket
        ]
      },
      {
        # Access to KMS key for encryption/decryption
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

# ==============================================================================
# DYNAMODB ACCESS POLICY
# ==============================================================================
# WHY: EC2 instances need to read/write payroll data to DynamoDB
# ==============================================================================

resource "aws_iam_policy" "dynamodb_access" {
  name_prefix = "${var.app_name}-dynamodb-policy"
  description = "Allow EC2 to access payroll DynamoDB table"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

# ==============================================================================
# CLOUDWATCH LOGS POLICY
# ==============================================================================
# WHY: EC2 instances should send application logs to CloudWatch
# BENEFIT: Centralized logging, debugging, monitoring
# ==============================================================================

resource "aws_iam_policy" "cloudwatch_logs" {
  name_prefix = "${var.app_name}-cloudwatch-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ==============================================================================
# ATTACH POLICIES TO ROLE
# ==============================================================================

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

# AWS managed policy for SSM Session Manager (secure SSH alternative)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ==============================================================================
# INSTANCE PROFILE
# ==============================================================================
# WHY: This is what you actually attach to EC2 instances
# ANALOGY: IAM Role is like a badge, Instance Profile is the badge holder
# ==============================================================================

resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${var.app_name}-ec2-profile"
  role        = aws_iam_role.ec2.name
  
  tags = {
    Name = "${var.app_name}-ec2-profile"
  }
}