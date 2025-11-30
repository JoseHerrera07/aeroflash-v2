# infra/provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1" 

  # Tags para gestión de costos.
  default_tags {
    tags = {
      Project     = "AeroFlash"
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}
