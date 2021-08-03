# variable machine_type {
#   default = "n1-standard-1"
# }


# variable "num_nodes" {
#   default     = 1
#   description = "number of nodes"
# }

variable "region" {}

resource "random_id" "repo" {
  byte_length = 8
}

resource "google_artifact_registry_repository" "my-repo"     {
  provider = google-beta
  project = var.project_id
  location = var.region
  # repository_id = lower(random_id.repo.hex)
  repository_id = "my-first-repo"
  description = "My first Google repo"
  format = "DOCKER"
}

resource "random_id" "repo-account" {
  byte_length = 8
}

resource "google_service_account" "repo-account" {
  provider = google-beta
  project = var.project_id
  # account_id   = lower(random_id.repo-account.hex)
  account_id = "repoaccount"
  display_name = "Repository Service Account"
}

resource "google_artifact_registry_repository_iam_member" "member" {  
  provider = google-beta
  project = google_artifact_registry_repository.my-repo.project
  location = google_artifact_registry_repository.my-repo.location
  repository = google_artifact_registry_repository.my-repo.name
  role   = "roles/artifactregistry.repoAdmin"
  member = "serviceAccount:${google_service_account.repo-account.email}"
}








# resource "google_compute_disk" "default" {
#   name  = "test-disk"
#   type  = "pd-standard"
#   size  = 10
#   zone  = var.zone
#   image = "debian-9-stretch-v20200805"
#   labels = {
#     environment = "dev"
#   }
#   physical_block_size_bytes = 4096
# }

