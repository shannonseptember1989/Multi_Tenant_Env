variable "environment"          { type = string }
variable "github_org"           { type = string }
variable "github_repo"          { type = string }
variable "state_bucket_name"    { type = string }
variable "lock_table_name"      { type = string  default = "terraform-state-lock" }
variable "create_oidc_provider" { type = bool    default = true }
variable "default_tags"         { type = map(string)  default = {} }
