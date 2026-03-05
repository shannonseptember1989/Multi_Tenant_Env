variable "environment"          { type = string }
variable "aws_region"           { type = string }
variable "github_org"           { type = string }
variable "github_repo"          { type = string }
variable "tf_state_bucket"      { type = string }
variable "tf_lock_table"        { type = string }
variable "cluster_name"         { type = string }
variable "k8s_version"          { type = string }
variable "node_instance_type"   { type = string }
variable "node_count_min"       { type = number }
variable "node_count_desired"   { type = number }
variable "node_count_max"       { type = number }
variable "vpc_cidr"             { type = string }
variable "public_subnet_cidrs"  { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "availability_zones"   { type = list(string) }
variable "ecr_repository_name"  { type = string  default = "wordpress" }
variable "default_tags"         { type = map(string)  default = {} }
