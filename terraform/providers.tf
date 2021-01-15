#
# Provider Configuration
#

provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

terraform {
  backend "s3" {
  }
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {} 

# EKS auth info
data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

# This is the main provider
# provider "kubernetes" {
#   version = "~> 1.13"
#   host                   = data.aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#   load_config_file       = false
#   exec {
#     api_version = "client.authentication.k8s.io/v1alpha1"
#     command = "aws" # this is the actual 'aws' cli tool
#     args = ["--region", var.region, "eks", "get-token", "--cluster-name", var.cluster_name]
#     env = {}
#   }
# }

# # This is so we can do CRDs and arbitrary yaml
# provider "kubernetes-alpha" {
#   version = "~> 0.2"
#   host                   = data.aws_eks_cluster.eks.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)

#   exec = {
#     api_version = "client.authentication.k8s.io/v1alpha1"
#     command = "aws" # this is the actual 'aws' cli tool
#     args = ["--region", var.region, "eks", "get-token", "--cluster-name", var.cluster_name]
#     env = {}
#   }
# }

# # This is so we can install the alb-ingress and cluster autoscaler
# provider "helm" {
#   version = "~> 1.3"
#   kubernetes {
#     host                   = data.aws_eks_cluster.eks.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#     load_config_file       = false
#     exec {
#       api_version = "client.authentication.k8s.io/v1alpha1"
#       command = "aws" # this is the actual 'aws' cli tool
#       args = ["--region", var.region, "eks", "get-token", "--cluster-name", var.cluster_name]
#       env = {}
#     }
#   }
# }
