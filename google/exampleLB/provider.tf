variable "project_id" {}
provider "google" {
  credentials = file("google_keys.json")
  project     = var.project_id
  region      = "us-central1"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region = "eu-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}