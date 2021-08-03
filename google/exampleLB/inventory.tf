variable "private_key_path" {}

resource "local_file" "hosts_config" {
  content = templatefile("${path.module}/tf_templates/hosts.tpl",
    {
        host_fqdn = aws_route53_record.saas_lb.fqdn
        host_ip = google_compute_instance.nginx_node.network_interface.0.access_config.0.nat_ip
        path_to_private_key = var.private_key_path
    }
  )
  filename = "./inventory/ansible_inventory.yml"
}