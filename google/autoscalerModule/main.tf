resource "google_service_account" "instances_service_account" {
  account_id   = "instances-service-account-id"
  display_name = "Instances Service Account"
  description = "Service account for instances"
  project = var.project_id
}

module "vm_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "6.6.0"
  disk_encryption_key = ""
  gpu = null
  min_cpu_platform = var.min_cpu_platform
  project_id = var.project_id
  region = var.region
  service_account = {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  =  google_service_account.instances_service_account.email
    scopes = ["cloud-platform"]
  }
  
  access_config = [
    {
      nat_ip=null,
      network_tier = var.network_tier
    }
  ]
  
  
  auto_delete = true
  can_ip_forward = false
  disk_labels = {
    environment = var.environment
  }
  
  disk_size_gb = var.boot_disk_size
  disk_type = var.boot_disk_type
  
  labels = {
    environment = var.environment
  }
  
  machine_type = var.machine_type
  
  metadata = {
    environment = var.environment
    enable-oslogin = "TRUE"    
  }
  
  name_prefix = var.instance_template_name_prefix
  network = module.network.network_self_link
  // Chose subnet with proper name with for or some function
  subnetwork = module.network.subnets_ids[0]
  on_host_maintenance = var.instance_on_host_maintenance
  preemptible = var.instance_preemptible
  //Select custom made image
  source_image = "bootdisk"
  source_image_project = var.project_id
  source_image_family = ""

  tags = [var.environment, "bastion"]
}

module "vm_mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "6.6.0"
  mig_name = var.mig_name
  instance_template = module.vm_instance_template.self_link
  project_id = var.project_id
  region = var.region
  autoscaling_enabled = var.autoscaling_enabled
  autoscaler_name = "instance-autoscaler"
  autoscaling_cpu = [tomap({"target" = var.autoscaler_cpu_threshold})]
  # autoscaling_lb
  # autoscaling_metric
  # autoscaling_scale_in_control
  cooldown_period = var.autoscaler_cooldown_period
  # health_check = { 
  #   "check_interval_sec": 30,
  #   "healthy_threshold": 1,
  #   "host": "", "initial_delay_sec": 30,
  #   "port": 80,
  #   "proxy_header": "NONE",
  #   "request": "",
  #   "request_path": "/",
  #   "response": "",
  #   "timeout_sec": 10,
  #   "type": "",
  #   "unhealthy_threshold": 5
  #   }
  
  # health_check_name

  hostname = var.instances_hostname_prefix
  min_replicas= var.instances_min_replicas
  max_replicas= var.instances_max_replicas
  named_ports = [{
    name = var.service_port_name,
    port = var.service_port,
  }]
  network = module.network.network_self_link
  // Chose subnet with proper name with for or some function
  subnetwork = module.network.subnets_ids[0]
  wait_for_instances = var.mig_wait_for_instances
  target_pools = [google_compute_target_pool.default.id]
}

resource "google_compute_target_pool" "default" {
  name = "instance-pool"
}

# resource "null_resource" "patience" {
#     depends_on = [google_compute_target_pool.default]
#     triggers = {
#       instance_ids = join(",", google_compute_target_pool.default.instances[*])
#     }

#     provisioner "local-exec" {
#       command = "sleep 30"
#     }
# }

module "address" {
  source  = "terraform-google-modules/address/google"
  version = "3.0.0"
  project_id = var.project_id
  region = var.region
  address_type = "EXTERNAL"
  global = true
  network_tier = var.network_tier
  subnetwork = ""
}

resource "google_compute_backend_service" "lb_backend_instance_pool" {
  name        = "backend"
  port_name   = var.service_port_name
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group                 = module.vm_mig.instance_group
  }

  health_checks = [google_compute_http_health_check.check_lb_backend.id]
}

resource "google_compute_http_health_check" "check_lb_backend" {
  name               = "check-backend"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}


module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 4.4"

  project           = var.project_id
  name              = "group-http-lb"
  # target_tags       = [module.mig1.target_tags, module.mig2.target_tags]
  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = var.service_port
      port_name                       = var.service_port_name
      timeout_sec                     = 10
      enable_cdn                      = false
      custom_request_headers          = null
      custom_response_headers         = null
      security_policy                 = null

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = var.service_port
        host                = null
        logging             = null
      }

      log_config = {
        enable = true
        sample_rate = 1.0
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = module.vm_mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}











# data "google_compute_instance" "appserver" {
#   for_each = tolist(["${null_resource.patience.triggers.instance_ids}"])
#   self_link = "projects/${var.project_id}/zones/${replace(each.key, "//.+/", "")}/instances/${replace(each.key, "/.+//", "")}"
#   depends_on = [null_resource.patience]
# }

# output "ips" {
#   value = data.google_compute_instance.appserver.network_interface[0].access_config[0].nat_ip
# }
