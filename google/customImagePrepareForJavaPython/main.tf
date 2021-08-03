variable project_id {}
variable zone {}
variable region {}
variable machine_type {}
variable boot_disk_image {}
variable public_key_path {}
variable boot_disk_name {}


resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_compute_instance" "instance-to-make-boot-image" {
  name         = "bootinstance"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["boot-image"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
    }
    auto_delete = false
    device_name = var.boot_disk_name
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    usage = "boot_disk_to_main_images"
    ssh-keys = "degor:${file(var.public_key_path)}"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

output "instance_external_ip" {
  value = google_compute_instance.instance-to-make-boot-image.network_interface[0].access_config[0].nat_ip
}