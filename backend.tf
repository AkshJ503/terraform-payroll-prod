# ==============================================================================
# TERRAFORM REMOTE STATE CONFIGURATION
# ==============================================================================
# WHY: Store Terraform state in S3 instead of local machine
# BENEFITS:
#   1. Team collaboration - multiple people can work together
#   2. State locking - prevents concurrent modifications (using DynamoDB)
#   3. Versioning - S3 keeps history of state changes
#   4. Security - state file may contain sensitive data, S3 encrypts it
# ==============================================================================

terraform {
  backend "s3" {
    # S3 bucket where Terraform state will be stored
    # IMPORTANT: Create this bucket manually BEFORE running terraform init
    bucket = "flexit-payroll-terraform-state"
    
    # Path within the bucket - organize by environment
    key = "payroll/prod/terraform.tfstate"
    
    # AWS region where S3 bucket exists
    region = "us-east-1"
    
    # Enable encryption at rest for security compliance
    encrypt = true
    
    # DynamoDB table for state locking
    # Prevents two people from modifying infrastructure simultaneously
    # Table must have a partition key named "LockID" (String type)
    dynamodb_table = "terraform-state-lock"
    
    # Server-side encryption with AWS KMS
    # Better security than default S3 encryption
    kms_key_id = "alias/terraform-state-key"
  }
}