variable "username" {}
variable "dns_ttl" {}
variable "dns_zone" {}
variable "geo_zone" {}
variable "webserver_port" {}

resource "google_compute_global_address" "saas_lb" {
  name = "saaslbexternalip"
}

data "aws_route53_zone" "selected" {
  name         = join("", [var.dns_zone, "."])
  private_zone = false
}

resource "aws_route53_record" "saas_lb" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = join("", [var.username, ".", data.aws_route53_zone.selected.name])
  type    = "A"
  ttl     = var.dns_ttl
  records = [google_compute_global_address.saas_lb.address]
}

resource "google_compute_global_forwarding_rule" "saas_lb" {
  provider              = google
  name                  = "global-rule"
  target                = google_compute_target_http_proxy.saas_lb.id
  port_range            = var.webserver_port
  ip_address            = google_compute_global_address.saas_lb.address
}

resource "google_compute_target_http_proxy" "saas_lb" {
  provider    = google
  name        = "target-proxy"
  url_map     = google_compute_url_map.saas_lb.id
}

resource "google_compute_url_map" "saas_lb" {
  provider        = google
  name            = "url-map-target-proxy"
  default_service = google_compute_backend_service.saas_lb.id

  host_rule {
    hosts        = [aws_route53_record.saas_lb.name]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.saas_lb.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.saas_lb.id
    }
  }
}

resource "google_compute_backend_service" "saas_lb" {
  name        = "backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group                 = google_compute_instance_group.webservers.id
  }

  health_checks = [google_compute_http_health_check.saas_lb.id]
}

resource "google_compute_http_health_check" "saas_lb" {
  name               = "check-backend"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}


resource "google_compute_instance" "nginx_node" {
  name         = "nginxnode"
  machine_type = "f1-micro"
  zone         = var.geo_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  
  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "degor:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = "echo hi > /test.txt"

  provisioner "local-exec" {
    command = "ssh-keyscan -H ${self.network_interface.0.access_config.0.nat_ip} >> ~/.ssh/known_hosts"
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${self.network_interface.0.access_config.0.nat_ip}"
  }
}

resource "google_compute_instance_group" "webservers" {
  name        = "terraform-webservers"
  
  instances = [
    google_compute_instance.nginx_node.id,
  ]
  
  zone = var.geo_zone
}

output "Settings" {
    value = join("", formatlist("\nGlobal IPv4 address: %s\nURL: %s\nVM IPv4: %s", google_compute_global_address.saas_lb.address, aws_route53_record.saas_lb.name, google_compute_instance.nginx_node.network_interface.0.access_config.0.nat_ip))
}