### `README.md`
````markdown
# Production-Grade AWS Payroll Infrastructure

This Terraform project deploys a highly available, secure, and scalable payroll application on AWS.

## Architecture

- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **Compute**: EC2 instances in Auto Scaling Group (min 2, max 10)
- **Load Balancing**: Application Load Balancer with health checks
- **Storage**: S3 for payslips, DynamoDB for payroll data
- **Security**: Security Groups, IAM roles, KMS encryption
- **Monitoring**: CloudWatch metrics and alarms

## Prerequisites

1. AWS account with appropriate permissions
2. Terraform >= 1.0 installed
3. AWS CLI configured
4. S3 bucket for Terraform state (create manually)
5. DynamoDB table for state locking (create manually)

## Setup Remote State (One-Time)
```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket flexit-payroll-terraform-state \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket flexit-payroll-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

## Deployment

### Development Environment
```bash
terraform init
terraform plan -var-file="env/dev.tfvars"
terraform apply -var-file="env/dev.tfvars"
```

### Production Environment
```bash
terraform init
terraform plan -var-file="env/prod.tfvars"
terraform apply -var-file="env/prod.tfvars"
```

## Outputs

After deployment, Terraform displays:
- ALB DNS name (application URL)
- S3 bucket name
- DynamoDB table name

## Cost Estimation

**Development (~$50/month)**:
- 1 x t2.micro EC2 instance
- 1 x Application Load Balancer
- 1 x NAT Gateway
- S3 + DynamoDB (usage-based)

**Production (~$200/month)**:
- 2-10 x t2.medium EC2 instances
- 1 x Application Load Balancer
- 2 x NAT Gateways (multi-AZ)
- S3 + DynamoDB (usage-based)

## Cleanup
```bash
terraform destroy -var-file="env/prod.tfvars"
```

## Security Best Practices

✅ IAM roles (no access keys)
✅ Security Groups (least privilege)
✅ Encryption at rest (S3, DynamoDB, EBS)
✅ Encryption in transit (HTTPS)
✅ Private subnets for EC2
✅ Multi-AZ deployment
✅ Automated backups

## Monitoring

- CloudWatch alarms for high/low CPU
- ALB health checks
- DynamoDB point-in-time recovery
- S3 versioning enabled
````

---

## 🚀 Usage Commands
````bash
# 1. Initialize Terraform
terraform init

# 2. Validate configuration
terraform validate

# 3. Format code
terraform fmt -recursive

# 4. Plan deployment (dev)
terraform plan -var-file="env/dev.tfvars"

# 5. Deploy infrastructure
terraform apply -var-file="env/prod.tfvars" -auto-approve

# 6. Show outputs
terraform output

# 7. Destroy infrastructure
terraform destroy -var-file="env/prod.tfvars"

# 8. Refresh state
terraform refresh

# 9. Show current state
terraform show

# 10. List resources
terraform state list
````

---

## ✅ What This Project Demonstrates

### Terraform Skills
✅ Modules (reusable infrastructure)
✅ Variables and outputs
✅ Remote state management
✅ State locking
✅ Data sources
✅ Count and for_each
✅ Lifecycle rules
✅ Dependencies
✅ Provisioners

### AWS Skills
✅ VPC networking
✅ Multi-AZ deployment
✅ Auto Scaling
✅ Load balancing
✅ IAM roles and policies
✅ Security Groups
✅ S3 encryption
✅ DynamoDB
✅ CloudWatch monitoring

### Production Best Practices
✅ High availability (multi-AZ)
✅ Auto-healing (health checks)
✅ Auto-scaling (dynamic capacity)
✅ Security (encryption, least privilege)
✅ Monitoring (CloudWatch)
✅ Cost optimization (lifecycle policies)
✅ Disaster recovery (backups)