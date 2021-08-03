resource "local_file" "hosts_config" {
  content = templatefile("${path.module}/tf_templates/hosts.tpl",
    {
        host_ip = google_compute_instance.instance-to-make-boot-image.network_interface[0].access_config[0].nat_ip
        path_to_private_key = var.public_key_path
    }
  )
  filename = "./inventory/ansible_inventory.yml"
}