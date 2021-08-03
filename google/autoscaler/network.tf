resource "google_compute_network" "default" {
  name = "my-network"
  # routing_mode = "REGIONAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "appvmnet" {
  name          = "appvmnet"
  ip_cidr_range = "10.1.0.0/16"
  region        = var.region
  network       = google_compute_network.default.id
}



resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.default.name
  direction = "INGRESS"
  
  allow {
    protocol = var.firewall_allow_protocol ? "icmp" : ""
  }

  allow {
    protocol = "tcp"
    ports    = var.firewall_allow_tcp_ports
  }

  # source_tags = ["web"]
}

# resource "google_compute_address" "internalvmaddr" {
#   name         = "my-internal-address"
#   subnetwork   = google_compute_subnetwork.appvmnet.id
#   address_type = "INTERNAL"
#   # address      = "10.0.42.42"
#   region       = var.region
#}