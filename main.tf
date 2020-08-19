module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = var.cluster_name
  region                     = var.region
  regional                   = false
  zones                      = [var.zone]
  network                    = module.gcp-network.network_name
  subnetwork                 = module.gcp-network.subnets_names[0]
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  create_service_account     = true
  http_load_balancing        = true
  horizontal_pod_autoscaling = true
  network_policy             = true
  remove_default_node_pool   = true

  node_pools = [
    {
      name                     = "test-node-pool"
      machine_type             = "g1-small"
      disk_size_gb             = 10
      disk_type                = "pd-standard"
      image_type               = "COS"
      auto_repair              = true
      auto_upgrade             = true
      preemptible              = true
      regional                 = false
      autoscaling              = true
      min_count                = 1
      max_count                = 2
      initial_node_count       = 1
    },
  ]
}

resource "kubernetes_deployment" "deployment_example" {
  metadata {
    name = "deployment-example"
    labels = {
      app = "app-example"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "app-example"
      }
    }

    template {
      metadata {
        labels = {
          app = "app-example"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx"

          port {
            container_port = 80
          }

          resources {
            requests {
              cpu = "50m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nodeport_example" {
  metadata {
    name = "nodeport-example"
  }

  spec {
    selector = {
      app = kubernetes_deployment.deployment_example.metadata[0].labels.app
    }

    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"

  }
}

resource "kubernetes_ingress" "ingress_example" {
  metadata {
    name = "ingress-example"

    annotations = {
      "kubernetes.io/ingress.allow-http"            = "false"
      "kubernetes.io/ingress.global-static-ip-name" = "test-static-ip"
      "ingress.gcp.kubernetes.io/pre-shared-cert"   = google_compute_managed_ssl_certificate.ssl_cert.name
    }
  }

  spec {
    rule {
      host = "kurigohan.ddo.jp"

      http {
        path {
          path = "/*"

          backend {
            service_name = kubernetes_service.nodeport_example.metadata[0].name
            service_port = 80
          }
        }
      }
    }
  }
}