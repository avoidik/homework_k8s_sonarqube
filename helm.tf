variable "minikube_profile" {
  type    = "string"
  default = "demo"
}

provider "helm" {
  kubernetes {
    config_context = "${var.minikube_profile}"
  }
}

provider "kubernetes" {
  config_context = "${var.minikube_profile}"
}

resource "kubernetes_namespace" "mysql" {
  metadata {
    name = "mysql"
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

resource "helm_release" "mysql" {
  name       = "mysql"
  chart      = "stable/mysql"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  version    = "1.6.2"
  namespace  = "mysql"
  atomic     = true
  values     = ["${file("${path.root}/values/mysql.yaml")}"]
  depends_on = ["kubernetes_namespace.mysql"]
}

resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  chart      = "stable/sonarqube"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  version    = "3.4.0"
  namespace  = "sonarqube"
  atomic     = true
  values     = ["${file("${path.root}/values/sonarqube.yaml")}"]
  depends_on = ["kubernetes_namespace.sonarqube", "helm_release.mysql"]
}
