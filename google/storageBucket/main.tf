resource "random_id" "bucket" {
  byte_length = 8
}

resource "google_storage_bucket" "tfstate-storage" {
  name          = "gcs-bucket-${random_id.bucket.hex}"
  location      = var.bucket_location
  force_destroy = true
  storage_class = var.bucket_storage_class  
  versioning {
    enabled   = var.bucket_object_versioning
  }
  
  # encryption {

  # }

  
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = var.bucket_noncurrent_object_days_to_live
    }
    action {
      type = "Delete"
    }
  }
}