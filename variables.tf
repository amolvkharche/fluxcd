variable "cluster_name" {
  type    = string
  default = "k8s-cluster"
}
variable "region" {
  type    = string
  default = "blr1"
}
variable "size" {
  type    = string
  default = "s-1vcpu-1gb"
}
variable "image" {
  type    = string
  default = "ubuntu-24-04-x64"
}
variable "do_token" {
  type      = string
  default   = ""
  sensitive = true
}
variable "k8s_version" {
  type    = string
  default = "1.29.1-do.0"
}

variable "registry_server" {
  type    = string
  default = "https://hub.docker.com/"
}
variable "registry_username" {
  type = string
}
variable "registry_password" {
  type = string
}
variable "registry_email" {
  type    = string
  default = "amolvkharche@gmail.com"
}
variable "git_url" {
  type = string
}

variable "git_username" {
  type = string
}

variable "git_token" {
  type      = string
  sensitive = true
}

variable "namespace" {
  description = "List of namespaces to create"
  type        = list(string)
}

variable "repos" {
  type        = list(string)
  description = "List of repository deployment file paths"
}

variable "namespace_map" {
  default = {
    "production" = "blu-prod"
    "staging"    = "blu-staging"
    "uat"        = "blu-uat"
  }
}
