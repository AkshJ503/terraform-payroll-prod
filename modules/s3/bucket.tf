# ==============================================================================
# KMS KEY for S3 Encryption
# ==============================================================================
# WHY: Encrypt payroll documents with customer-managed key
# BENEFIT: You control the encryption key, meet compliance requirements
# ==============================================================================

resource "aws_kms_key" "s3" {
  description             = "KMS key for encrypting payroll S3 bucket"
  deletion_window_in_days = 10  # Waiting period before permanent deletion
  enable_key_rotation     = true  # Automatic annual key rotation
  
  tags = {
    Name = "${var.app_name}-s3-kms-key"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.app_name}-s3-encryption"
  target_key_id = aws_kms_key.s3.key_id
}

# ==============================================================================
# S3 BUCKET for Payslips
# ==============================================================================
# WHY: Store employee payslips, documents, uploads
# ==============================================================================

resource "aws_s3_bucket" "payroll" {
  bucket = "${var.app_name}-payslips-${var.environment}"
  
  tags = {
    Name = "${var.app_name}-payslips"
  }
}

# ==============================================================================
# ENABLE VERSIONING
# ==============================================================================
# WHY: Keep history of all file changes
# BENEFIT: Recover from accidental deletions, meet audit requirements
# ==============================================================================

resource "aws_s3_bucket_versioning" "payroll" {
  bucket = aws_s3_bucket.payroll.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# ==============================================================================
# ENABLE ENCRYPTION
# ==============================================================================
# WHY: Payroll data is sensitive, must be encrypted at rest
# COMPLIANCE: Required for SOC2, PCI-DSS, GDPR
# ==============================================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "payroll" {
  bucket = aws_s3_bucket.payroll.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# ==============================================================================
# BLOCK PUBLIC ACCESS
# ==============================================================================
# WHY: Prevent accidental exposure of sensitive payroll documents
# BEST PRACTICE: Always block public access for sensitive data
# ==============================================================================

resource "aws_s3_bucket_public_access_block" "payroll" {
  bucket = aws_s3_bucket.payroll.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==============================================================================
# LIFECYCLE POLICY
# ==============================================================================
# WHY: Automatically move old files to cheaper storage
# BENEFIT: Save costs while meeting retention requirements
# ==============================================================================

resource "aws_s3_bucket_lifecycle_configuration" "payroll" {
  bucket = aws_s3_bucket.payroll.id
  
  rule {
    id     = "archive-old-payslips"
    status = "Enabled"
    
    # Move files to cheaper storage after 90 days
    transition {
      days          = 90
      storage_class = "STANDARD_IA"  # Infrequent Access
    }
    
    # Move to Glacier after 1 year (for long-term compliance)
    transition {
      days          = 365
      storage_class = "GLACIER"
    }
    
    # Delete after 7 years (adjust based on legal requirements)
    expiration {
      days = 2555
    }
  }
}

# ==============================================================================
# BUCKET POLICY
# ==============================================================================
# WHY: Enforce SSL/TLS for all requests
# SECURITY: Prevent unencrypted data transmission
# ==============================================================================

resource "aws_s3_bucket_policy" "payroll" {
  bucket = aws_s3_bucket.payroll.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.payroll.arn,
          "${aws_s3_bucket.payroll.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}