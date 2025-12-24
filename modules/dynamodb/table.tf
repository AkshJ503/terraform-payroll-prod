# ==============================================================================
# DYNAMODB TABLE for Payroll Data
# ==============================================================================
# WHY: Store employee payroll records (NoSQL database)
# BENEFITS: Fast, scalable, serverless, automatic backups
# ==============================================================================

resource "aws_dynamodb_table" "payroll" {
  name           = "${var.app_name}-payroll-data"
  billing_mode   = "PAY_PER_REQUEST"  # Auto-scales, pay only for what you use
  hash_key       = "EmployeeID"       # Partition key (must be unique)
  
  # Define attributes (columns)
  attribute {
    name = "EmployeeID"
    type = "S"  # String type
  }
  
  # Optional: Add a sort key for more complex queries
  # attribute {
  #   name = "PayPeriod"
  #   type = "S"
  # }
  # range_key = "PayPeriod"
  
  # ==============================================================================
  # POINT-IN-TIME RECOVERY
  # ==============================================================================
  # WHY: Continuous backups, restore to any point in last 35 days
  # USE CASE: Recover from accidental data deletion or corruption
  # ==============================================================================
  
  point_in_time_recovery {
    enabled = true
  }
  
  # ==============================================================================
  # ENCRYPTION AT REST
  # ==============================================================================
  # WHY: Payroll data must be encrypted
  # ==============================================================================
  
  server_side_encryption {
    enabled = true
  }
  
  # ==============================================================================
  # TIME TO LIVE (TTL)
  # ==============================================================================
  # WHY: Automatically delete old records after a certain time
  # EXAMPLE: Delete temporary session data after 24 hours
  # ==============================================================================
  
  ttl {
    attribute_name = "ExpirationTime"
    enabled        = false  # Enable if needed
  }
  
  tags = {
    Name = "${var.app_name}-payroll-table"
  }
}