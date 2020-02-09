resource "kubernetes_persistent_volume" "mysql" {
  metadata {
    name = "mysql-volume"

    labels {
      app  = "mysql"
      type = "local"
    }
  }

  spec {
    storage_class_name = "manual-mysql"

    capacity = {
      storage = "10Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/mysql"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "sonarqube" {
  metadata {
    name = "sonarqube-volume"

    labels {
      app  = "sonarqube"
      type = "local"
    }
  }

  spec {
    storage_class_name = "manual-sonarqube"

    capacity = {
      storage = "10Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/sonarqube"
      }
    }
  }
}
