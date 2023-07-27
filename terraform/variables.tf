variable "project_id" {
  type        = string
  description = ""
  default     = "learn-experiment"
}

variable "region" {
  type        = string
  description = ""
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = ""
  default     = "us-central1-c"
}

variable "ip_cidr_range" {
  type        = string
  description = ""
  default     = "10.128.0.0/28"
}

variable "clone_url" {
    type        = string
    description = ""
    default     = "https://github.com/abhinavkbij/kfp-ml-pipeline.git"
    sensitive   = true
}

variable "gh_token" {
  type      = string
  sensitive = true
}

variable "gh_username" {
  type      = string
  sensitive = true
}

variable "gh_repo_name" {
    type = string
    sensitive = true
}