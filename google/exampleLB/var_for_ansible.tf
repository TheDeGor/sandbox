variable "nginx_worker_processes_count" {}
variable "nginx_worker_connections_count" {}
variable "index_types" {}

resource "local_file" "ansible_variables" {
  content = templatefile("${path.module}/tf_templates/vars.tpl",
    {
        server_fqdn = aws_route53_record.saas_lb.name
        host_ip = google_compute_instance.nginx_node.network_interface.0.access_config.0.nat_ip
        workers = var.nginx_worker_processes_count
        worker_conn = var.nginx_worker_connections_count
        webserver_port = var.webserver_port
        indexes = jsonencode(var.index_types.*)
    }
  )
  filename = "./roles/webservers/vars/main.yml"

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory/ansible_inventory.yml main.yml"
  }
}
