resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  provider = google-beta
  
  name = "test-ssl-cert"

  managed {
    domains = ["kurigohan.ddo.jp"]
  }
}
