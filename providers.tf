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
  config_path = local_file.kubeconfig.filename

}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}
