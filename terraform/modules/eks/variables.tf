variable "environment"         { type = string }
variable "cluster_name"        { type = string }
variable "k8s_version"         { type = string  default = "1.29" }
variable "node_instance_type"  { type = string }
variable "node_count_min"      { type = number }
variable "node_count_desired"  { type = number }
variable "node_count_max"      { type = number }
variable "vpc_id"              { type = string }
variable "public_subnet_ids"   { type = list(string) }
variable "private_subnet_ids"  { type = list(string) }
variable "ecr_repository_name" { type = string  default = "wordpress" }
variable "default_tags"        { type = map(string)  default = {} }
