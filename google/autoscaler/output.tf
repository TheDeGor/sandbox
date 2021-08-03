output "Instance_group_stability" {
  value = google_compute_instance_group_manager.igm.status[0].is_stable
}

output "Instances" {
  value = join(", ", google_compute_target_pool.target-pool.instances)
}

resource "local_file" "vars" {
  content = format("ZONE=\"%s\"\nENV=\"%s\"\nKEY_PATH=\"%s\"\ndeclare -a INSTANCES=(%s)", var.zone, var.environment, var.public_key_path, replace (join(" ", google_compute_target_pool.target-pool.instances), "${var.zone}/", ""))
  filename = "${path.module}/instances.raw"
  file_permission = 0644
  provisioner "local-exec" {
    command = "./inventory.sh"
  }
  depends_on = [
    google_compute_instance_group_manager.igm,
    google_compute_target_pool.target-pool,
    google_compute_autoscaler.vm-autoscaler
  ]
}

output "Load_balancer_external_ip" {
    value = google_compute_global_address.lb_ext_ip.address
}

# output "Instances_ip" {
#   value = time_sleep.instances_ip_propagation.triggers.instance_group
#   # .instances.*.network_interface.0.access_config.0.nat_ip]
# }
# output "instances_ips" {
#   value = time_sleep.instances_propagation.instances.*.network_interface.0.access_config.0.nat_ip
# }

# data "google_compute_instance" "instances_from_group" {
#   count = google_compute_instance_group_manager.igm.target_size > var.autoscaler_min_replicas ? google_compute_instance_group_manager.igm.target_size : var.autoscaler_min_replicas
#   name = replace (element (google_compute_target_pool.target-pool.instances, [count.index]), "${var.zone}/", "")
#   zone = var.zone
# }

# output "Instance_settings" {
#     value =  data.google_compute_instance.instances_from_group.*
#     # value = join("", formatlist("\nGlobal IPv4 address: %s\nURL: %s\nVM IPv4: %s", google_compute_global_address.saas_lb.address, aws_route53_record.saas_lb.name, google_compute_instance.nginx_node.network_interface.0.access_config.0.nat_ip))
# }

# resource "google_compute_instance_group" "igm" {
#   name        = "igm"
#   zone        = var.zone
#   network     = google_compute_network.default.id
# }

# data "google_compute_instance_group" "igm" {
#     self_link = "projects/${var.project_id}/zones/${var.zone}/instanceGroups/igm"
# }

# output "igm" {
#   value = google_compute_instance_group.igm
# }

