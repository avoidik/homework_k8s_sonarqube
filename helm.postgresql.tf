variable "minikube_profile" {
  type    = "string"
  default = "demo"
}

terraform {
  required_providers {
    helm       = "~> 1.0.0"
    kubernetes = "~> 1.10.0"
  }
}

provider "helm" {
  kubernetes {
    config_context = "${var.minikube_profile}"
  }
}

provider "kubernetes" {
  config_context = "${var.minikube_profile}"
}

resource "kubernetes_namespace" "postgresql" {
  metadata {
    name = "postgresql"
  }
}

resource "kubernetes_namespace" "sonarqube" {
  metadata {
    name = "sonarqube"
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "postgresql" {
  name       = "postgresql"
  chart      = "stable/postgresql"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  version    = "8.3.0"
  namespace  = "postgresql"
  atomic     = true
  values     = ["${file("${path.root}/values/postgresql.yaml")}"]
  depends_on = ["kubernetes_namespace.postgresql"]
}

resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  chart      = "stable/sonarqube"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  version    = "3.4.0"
  namespace  = "sonarqube"
  atomic     = true
  values     = ["${file("${path.root}/values/sonarqube.yaml")}"]
  depends_on = ["kubernetes_namespace.sonarqube", "helm_release.postgresql"]
}
