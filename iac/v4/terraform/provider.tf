# versions.tf
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Version     = "v3"
    }
  }
}

#provider "kubernetes" {
#  host                   = aws_eks_cluster.example.endpoint
#  cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority[0].data)
#  token                  = data.aws_eks_cluster_auth.example.token
#}
#
#provider "helm" {
#  kubernetes {
#    host                   = aws_eks_cluster.example.endpoint
#    cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority[0].data)
#    token                  = data.aws_eks_cluster_auth.example.token
#  }
#}
