resource "digitalocean_kubernetes_cluster" "test" {
  name    = var.cluster_name
  region  = var.region
  version = var.k8s_version
  tags    = ["${var.cluster_name}"]
  node_pool {
    name       = "${var.cluster_name}-worker-pool"
    size       = var.size
    auto_scale = true
    min_nodes  = 2
    max_nodes  = 3
  }
}
resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.test.kube_config.0.raw_config
  filename = "${path.module}/kubeconfig"
}

resource "kubernetes_namespace" "namespace" {
  for_each = toset(var.namespace)

  metadata {
    name = each.key
    annotations = {
      name = each.key
    }
    labels = {
      mylabel = each.key
    }
  }

  depends_on = [
    digitalocean_kubernetes_cluster.test, local_file.kubeconfig
  ]
}

resource "kubernetes_namespace" "fluxnamespace" {
  metadata {
    annotations = {
      name = "flux-system"
    }

    labels = {
      mylabel = "flux-system"
    }

    name = "flux-system"
  }
  depends_on = [
    digitalocean_kubernetes_cluster.test, local_file.kubeconfig
  ]
}

resource "null_resource" "create_flux_secret" {
  provisioner "local-exec" {
    command = "flux create secret git flux-repo-secret --url=${var.git_url}  --username=${var.git_username}   --bearer-token=${var.git_token} -n flux-system --kubeconfig=${local_file.kubeconfig.filename}"
  }
  depends_on = [
    kubernetes_namespace.fluxnamespace, local_file.kubeconfig
  ]
}

resource "kubernetes_secret" "image_pull_secret" {
  for_each = toset(var.namespace)
  metadata {
    name      = "my-secret"
    namespace = each.key
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.registry_username
          "password" = var.registry_password
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }
  depends_on = [
    digitalocean_kubernetes_cluster.test, local_file.kubeconfig
  ]
}
resource "helm_release" "blu_runwalcustomservice" {
  for_each = toset(var.namespace)

  name      = "blu-runwalcustomservice"
  namespace = each.key
  chart     = "./charts/blu-runwalcustomservice"

  set {
    name  = "imagePullSecrets[0].name"
    value = kubernetes_secret.image_pull_secret[each.key].metadata[0].name
  }

  values = [
    file(
      "${path.module}/environment/do/${lookup(var.namespace_folders, each.key, "production")}/app/blu-runwalcustomservice/release.yaml"
    ),

    file(
      "${path.module}/environment/do/${lookup(var.namespace_folders, each.key, "production")}/app/blu-runwalcustomservice/${each.key == "blu-prod" ? "prd" : each.key == "blu-staging" ? "dev" : each.key == "blu-uat" ? "uat" : null}.yaml"
    )
  ]
  timeout           = 300
  wait              = true
  recreate_pods     = false
  disable_crd_hooks = false

  depends_on = [
    digitalocean_kubernetes_cluster.test,
    local_file.kubeconfig,
    kubernetes_secret.image_pull_secret
  ]
}


resource "helm_release" "nginx_ingress" {
  name       = "nginx"
  namespace  = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.7.1"

  create_namespace = true

  values = [
    file("${path.module}/environment/do/production/nginx/nginx-ingress.yaml")
  ]
  depends_on = [
    digitalocean_kubernetes_cluster.test, local_file.kubeconfig
  ]
}

resource "helm_release" "app_deploy" {
  for_each         = toset(var.repos)
  name             = split("/", each.value)[4]
  namespace        = "default"
  chart            = "./charts/blu-runwalcustomservice"
  values           = [file(each.value)]
  timeout          = 300
  create_namespace = true
}
