terraform {
  backend "s3" {
    bucket       = "ivtkac-tf-state"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  extra_tag = "extra-tag"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name     = var.instance_name
    ExtraTag = local.extra_tag
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "12.22"
  instance_class      = "db.t3.micro"
  license_model       = "postgresql-license"
  name                = "mydb"
  username            = var.db_user
  password            = var.db_pass
  skip_final_snapshot = true
}
