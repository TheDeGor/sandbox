resource "google_compute_network" "default" {
  name = "my-network"
}

resource "google_compute_subnetwork" "appvmnet" {
  name          = "appvmnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.default.id
}

# resource "google_compute_address" "internalvmaddr" {
#   name         = "my-internal-address"
#   subnetwork   = google_compute_subnetwork.appvmnet.id
#   address_type = "INTERNAL"
#   # address      = "10.0.42.42"
#   region       = var.region
#}