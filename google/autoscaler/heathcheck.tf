resource "google_compute_http_health_check" "default" {
  name               = "default"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
resource "google_compute_health_check" "health-check-with-logging" {
  provider = google-beta

  name = "tcp-health-check"

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = var.autoscaler_min_replicas

  tcp_health_check {
    port = "22"
  }

  log_config {
    enable = true
  }
}

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}