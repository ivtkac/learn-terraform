---
created: 2025-12-01
title: How to store terraform state in AWS?
tags:
  - 🦮how-to
  - terraform
  - aws
  - config
aliases:
---
prev:: [[Що потрібно для зберігання terraform state віддалено у AWS?]]

> [!warning] Before run backend we need [[#1. Bootstraping|bootstrap]] bucket and dynamo db

```tf
terraform {
	backend "s3" {
		bucket = "your-unique-terraform-state-bucket-name"	
		key = "terraform.tfstate"
		region = "us-east-1"
		dynamodb_table = "terraform-state-locking"
		encrypt = true
	}
}
```

## 1. Bootstraping

1. default to local (without remote backend)
2. defined [[AWS S3]] and [[Dynamodb]]

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
```

```tf
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

2. Specified as S3 bucket
```tf
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket-name"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

- `terraform init`
- `terraform plan`