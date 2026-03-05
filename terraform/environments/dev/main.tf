terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = { source = "hashicorp/aws"  version = "~> 5.0" }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = var.default_tags }
}

module "vpc" {
  source               = "../../modules/vpc"
  environment          = var.environment
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  default_tags         = var.default_tags
}

module "eks" {
  source              = "../../modules/eks"
  environment         = var.environment
  cluster_name        = var.cluster_name
  k8s_version         = var.k8s_version
  node_instance_type  = var.node_instance_type
  node_count_min      = var.node_count_min
  node_count_desired  = var.node_count_desired
  node_count_max      = var.node_count_max
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  ecr_repository_name = var.ecr_repository_name
  default_tags        = var.default_tags
}

module "iam" {
  source               = "../../modules/iam"
  environment          = var.environment
  github_org           = var.github_org
  github_repo          = var.github_repo
  state_bucket_name    = var.tf_state_bucket
  lock_table_name      = var.tf_lock_table
  create_oidc_provider = true    # only dev creates the OIDC provider
  default_tags         = var.default_tags
}
