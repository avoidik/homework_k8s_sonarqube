resource "kubernetes_persistent_volume" "postgresql" {
  metadata {
    name = "postgresql-volume"

    labels {
      app  = "postgresql"
      type = "local"
    }
  }

  spec {
    storage_class_name = "manual-postgresql"

    capacity = {
      storage = "10Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/data/postgresql"
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
