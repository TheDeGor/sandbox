variable "bucket_location" {
  type = string
  default = "EU"
}

variable "bucket_storage_class" {
  type = string
  default = "STANDARD"
}

variable "bucket_object_versioning" {
  type = bool
  default = false
}

variable "bucket_noncurrent_object_days_to_live" {
  type = number
  default = 365
}

variable project_id {
  
}
variable zone {
  
}
variable region {
  
}