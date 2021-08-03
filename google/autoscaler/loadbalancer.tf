resource "google_compute_global_address" "lb_ext_ip" {
  name = "lbexternalip"
}


resource "google_compute_global_forwarding_rule" "lb_fwd_rule" {
  provider              = google
  name                  = "global-rule"
  target                = google_compute_target_http_proxy.lb_target_proxy.id
  port_range            = var.webserver_port
  ip_address            = google_compute_global_address.lb_ext_ip.address
}

resource "google_compute_target_http_proxy" "lb_target_proxy" {
  provider    = google
  name        = "target-proxy"
  url_map     = google_compute_url_map.lb_url_map.id
}

resource "google_compute_url_map" "lb_url_map" {
  provider        = google
  name            = "url-map-target-proxy"
  default_service = google_compute_backend_service.lb_backend_svc.id

  host_rule {
    hosts        = ["${google_compute_global_address.lb_ext_ip.address}.nip.io"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.lb_backend_svc.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.lb_backend_svc.id
    }
  }
}

resource "google_compute_backend_service" "lb_backend_svc" {
  name        = "backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group     = google_compute_instance_group_manager.igm.instance_group
  }

  health_checks = [google_compute_http_health_check.lb_health_check.id]
}

resource "google_compute_http_health_check" "lb_health_check" {
  name               = "check-backend"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
