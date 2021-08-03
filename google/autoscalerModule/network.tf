module "network" {
  source  = "terraform-google-modules/network/google"
  version = "3.3.0"
  network_name = "main-network"
  project_id = var.project_id
  subnets = [
        {
            subnet_name           = "subnet"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = var.region
            # subnet_private_access = "true"
            # subnet_flow_logs      = "true"
            # subnet_flow_logs_interval = "INTERVAL_10_MIN"
            # subnet_flow_logs_sampling = 0.7
            # subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
            description = "Frontend to Backend subnet"
        },
        # {
        #     subnet_name           = "back-db"
        #     subnet_ip             = "10.10.20.0/24"
        #     subnet_region         = var.region
        #     # subnet_private_access = "true"
        #     # subnet_flow_logs      = "true"
        #     # subnet_flow_logs_interval = "INTERVAL_10_MIN"
        #     # subnet_flow_logs_sampling = 0.7
        #     # subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
        #     description           = "Backend to DB subnet"
        # },
        # {
        #     subnet_name           = "bastion"
        #     subnet_ip             = "10.10.100.0/24"
        #     subnet_region         = var.region
        #     # subnet_private_access = "true"
        #     # subnet_flow_logs      = "true"
        #     # subnet_flow_logs_interval = "INTERVAL_10_MIN"
        #     # subnet_flow_logs_sampling = 0.7
        #     # subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
        #     description           = "Backend to DB subnet"
        # }
    ]
  
  
}

module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.network.network_name

  rules = [
    {
      name                    = "allow-ssh-ingress"
      description             = "Allow ssh-connection to nodes"
      direction               = "INGRESS"
      priority                = null
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-backend-to-databases"
      description             = "Allow backend nodes connection to databases instances"
      direction               = "INGRESS"
      priority                = null
      ranges                  = null
      source_tags             = ["backend"]
      source_service_accounts = null
      target_tags             = ["database"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = var.db_ports
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      name                    = "allow-fronend-to-backend"
      description             = "Allow frontend nodes connection to backend"
      direction               = "INGRESS"
      priority                = null
      ranges                  = null
      source_tags             = ["frontend"]
      source_service_accounts = null
      target_tags             = ["backend"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = var.backend_ports
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
  
  ]
}