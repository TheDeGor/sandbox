resource "google_service_account" "vm-service-account" {
  account_id   = var.gce_service_account_id
  display_name = "VM Service Account"
}

resource "google_compute_instance_template" "tpl" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."

  tags = ["web"]

  labels = {
    environment = var.environment
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

  network_interface {
    network = "${google_compute_network.default.id}"
    subnetwork = "${google_compute_subnetwork.appvmnet.id}"
    # network_ip = "${google_compute_address.internalvmaddr.address}"
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
    ssh-keys = "degor:${file(var.public_key_path)}"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.vm-service-account.email
    scopes = var.instance_sa_scopes
  }

}

resource "google_compute_target_pool" "target-pool" {
  provider = google-beta
  region = var.region
  name = "my-target-pool"
  
  # depends_on = [time_sleep.wait_30_seconds]
  # health_checks = [
  #   google_compute_http_health_check.default.name,
  # ]
  
  # timeouts {
  #   create = "1m"
  # }
}



resource "google_compute_instance_group_manager" "igm" {
  provider = google-beta

  name = "my-igm"
  zone = var.zone

  wait_for_instances = true
  wait_for_instances_status = "UPDATED"
  
  version {
    instance_template = google_compute_instance_template.tpl.id
    name              = "primary"
  }

  target_pools       = [google_compute_target_pool.target-pool.id]
  base_instance_name = "autoscaler-instance"
  # auto_healing_policies {
  #   health_check      = google_compute_health_check.autohealing.id
  #   initial_delay_sec = 300
  # }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_compute_instance_group_manager.igm]

  create_duration = "30s"
}

resource "google_compute_autoscaler" "vm-autoscaler" {
  name   = "my-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.igm.id

  autoscaling_policy {
    max_replicas    = var.autoscaler_max_replicas
    min_replicas    = var.autoscaler_min_replicas
    cooldown_period = 60
    mode            = "ON"

    cpu_utilization {
      target = var.autoscaler_target_cpu_utilization
      predictive_method = "NONE"
    }
  }
}