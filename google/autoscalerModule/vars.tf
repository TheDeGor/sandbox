variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "region" {
  type = string
}

variable "location" {
  type = string
}

variable "db_ports" {
  type = list(number)
}
variable "backend_ports" {
  type = list(number)
}
variable "min_cpu_platform" {
  type = string
  default = "Intel Sandy Bridge"
}

variable "boot_disk_size" {
  type = string
  default = "100"
}

variable "boot_disk_type" {
  type = string
  default = "pd-standard"
  validation {
    condition = contains(["pd-ssd", "local-ssd", "pd-standard"], var.boot_disk_type)
    error_message = "Boot disk type, can be either pd-ssd, local-ssd, or pd-standard."
  }
}

variable "machine_type" {
  type = string
  default = "n1-standard-1"
}

variable "remote_user_name" {
  type = string
}

variable "instance_template_name_prefix" {
  type = string
}

variable "instance_on_host_maintenance" {
  type = string
  default = "MIGRATE"
  validation {
    condition = contains(["MIGRATE", "TERMINATE"], var.instance_on_host_maintenance)
    error_message = "On host maintenance policy could be MIGRATE or TERMINATE."
  }
}
variable "network_tier" {
  type = string
  default = "PREMIUM"
  validation {
    condition = contains(["STANDARD", "PREMIUM"], var.network_tier)
    error_message = "Network tier could be STANDARD or PREMIUM."
  }
}

variable "instance_preemptible" {
  type = bool
  default = false
}

variable "boot_disk_image" {
  type = string
  default = "ubuntu-os-cloud/ubuntu-2010"
}

variable "environment" {
  type = string
  validation {
    condition = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "Choose one of the following to set the environment: dev, test, stage, prod."
  }
}

variable "public_key_path" {
  type = string
}

variable "autoscaler_name" {
  type = string
  default = "instance-autoscaler"
}

variable "autoscaler_cpu_threshold" {
  type = number
  validation {
    condition = (var.autoscaler_cpu_threshold > 0.0) && (var.autoscaler_cpu_threshold <= 1.0)
    error_message = "The target CPU utilization must be a float value in the range (0, 1]."
  }
}

variable "autoscaling_enabled" {
  type = bool
  default = false
}

variable "autoscaler_cooldown_period" {
  type = number
  default = 60
}

variable "instances_hostname_prefix" {
  type = string
  default = "autoscaler-instance"
}

variable "instances_min_replicas" {
  type = number
  default = 1
}

variable "instances_max_replicas" {
  type = number
  default = 10
}

variable "mig_name" {
  type = string
  default = "autoscaler-mig"
}

variable "mig_wait_for_instances" {
  type = bool
  default = false
}

variable "service_port" {
  type        = number
  default     = 80
}

variable "service_port_name" {
  type        = string
  default     = "http"
}
