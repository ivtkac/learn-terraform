---
created: 2025-12-02
title: How to store terraform remotely in AWS S3 bucket?
tags:
  - 🦮how-to
  - terraform
  - aws
  - config
aliases:
---
> [!warning] Before run backend we need create [[AWS S3|S3]] bucket and [[Dynamodb|dynamo db]]

### 1. Define resources S3 and DynamoDB

  
```tf
resource "aws_s3_bucket" "terraform_state" {
	bucket = "your-unique-terraform-state-bucket-name"
	tags = {
		Name = "Terraform State Bucket"
		Environment = "Production"
	}

	lifecycle {
		prevent_destroy = true
	}
}

resource "aws_s3_bucket_versioning" "terraform_state" {
	bucket = aws_s3_bucket.terraform_state.id
	versioning_configuration {
		status = "Enabled"
	}
}

resource "aws_s3_bucket_server_side_encyrption_configuration" "terraform_state" {
	bucket = aws_s3_bucket.terraform_state.id

	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Production"
  }
}
```

Then run and say yes

- `terraform plan`
- `terraform apply`

### 2. Specified backend

Add our bucket name, key (how state is called), and region:

```tf
terraform {
    backend "s3" {
        bucket = "your-unique-terraform-state-bucket-name"
        key = "terraform.tfstate"
        region = "eu-central-1"
        encrypt = true
        dynamo_db = "terraform-state-lock"
    }
}
```

Then run `terraform init` and answer yes.

After this we can remove resources for backend from our `main.tf` with:

```bash
terraform state rm aws_dynamodb_table.terraform_lock
terraform state rm aws_s3_bucket.terraform_state
terraform state rm aws_s3_bucket_public_access_block.name
terraform state rm aws_s3_bucket_server_side_encryption_configuration.terraform_state
terraform state rm aws_s3_bucket_versioning.terraform_state
```

Then work as usually.
