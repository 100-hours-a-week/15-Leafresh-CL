# provider.tf
terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.42.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.tag_environment
      Project     = var.project_name
      Version     = "v3"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
