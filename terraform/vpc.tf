# Purpose: Create a VPC with public and private subnets across multiple Availability Zones.

# Initialize AWS Provider with AWS region from var file.
provider "aws" {
  region = var.aws_region
}

# Fetch all available AWS Availability Zones.
data "aws_availability_zones" "available" {}

# Create a random string for the cluster name suffix.
locals {
  cluster_name = "mohzim-eks-${random_string.suffix.result}"
}

# Create a random string for the cluster name suffix.
resource "random_string" "suffix" {
  length  = 8
  special = false
}

# Create a VPC with public and private subnets across multiple Availability Zones.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name                 = "mohzim-eks-vpc"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tagging
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  # Subnet tags
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  # Subnet tags
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
