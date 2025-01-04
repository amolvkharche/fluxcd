terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.46"
    }
  }
}
provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  config_path = "C:/Users/vaibh/digitalOceank8s/kubeconfig" # Adjust based on your kubeconfig file

}

provider "helm" {
  kubernetes {
    config_path = "C:/Users/vaibh/digitalOceank8s/kubeconfig"
  }
}
