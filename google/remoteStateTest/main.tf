data "terraform_remote_state" "common" {
  backend = "gcs"

  config = {
    bucket  = "gcs-bucket-bb711e3712e43380"
    prefix  = "terraform/state"
  }
}

output "remote_value" {
  value = data.terraform_remote_state.common.outputs.Load_balancer_external_ip
}