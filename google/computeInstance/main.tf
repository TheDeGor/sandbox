variable machine_type {}
variable region {}
variable zone {}
variable boot_disk_image {}
variable exist_disk_image {}
variable exist_disk_capacity {}
variable exist_disk_type {}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "VM Service Account"
}

resource "google_compute_instance_template" "tpl" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."

  tags = ["foo", "bar"]

  labels = {
    environment = "dev"
  }

  instance_description = "description assigned to instances"
  machine_type         = var.machine_type
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image      = var.boot_disk_image
    auto_delete       = true
    boot              = true
    // backup the disk every day
    # resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  // Use an existing disk resource
  disk {
    // Instance Templates reference disks by name, not self link
    source      = google_compute_disk.foobar.name
    auto_delete = false
    boot        = false
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.appvmnet.id}"
    # network_ip = "${google_compute_address.internalvmaddr.address}"
    
  }

  metadata = {
    foo = "bar"
    ssh-keys = "degor:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

}

# data "google_compute_image" "my_image" {
#   family  = "ubuntu-2010"
#   project = "ubuntu-os-cloud"
# }

      

resource "google_compute_disk" "foobar" {
  name  = "existing-disk"
  image = var.exist_disk_image
  # image = data.google_compute_image.my_image.id
  size  = var.exist_disk_capacity
  type  = var.exist_disk_type
  zone  = var.zone
  labels = {
    environment = "dev"
  }
}

# resource "google_compute_resource_policy" "daily_backup" {
#   name   = "every-day-4am"
#   region = var.region
#   snapshot_schedule_policy {
#     schedule {
#       daily_schedule {
#         days_in_cycle = 1
#         start_time    = "04:00"
#       }
#     }
#   }
# }


resource "google_compute_instance_from_template" "tpl" {
  name = "instance-from-template"
  zone = var.zone

  source_instance_template = google_compute_instance_template.tpl.id

  // Override fields from instance template
  can_ip_forward = false
  labels = {
    my_key = "my_value"
  }
}