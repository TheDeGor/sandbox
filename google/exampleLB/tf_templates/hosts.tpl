webservers:
  hosts:
    ${host_fqdn}:
      ansible_host: ${host_ip}
      ansible_ssh_private_key_file: ${path_to_private_key}
