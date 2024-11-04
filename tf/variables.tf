variable "gcp_project_id" {
  description = "The ID of the GCP project to use"
}

variable "gcp_region" {
  description = "The GCP region where resources should be created"
  default     = "europe-west2"
}

variable "gcp_zone" {
  description = "value of the GCP zone"
  default     = "europe-west2-a"
}

variable "server_instance_count" {
  description = "The number of server instances to create"
  default     = 3
}

variable "cts_instance_count" {
  description = "The number of cts instances to create"
  default     = 0
}

variable "nginx_instance_count" {
  description = "The number of nginx instances to create"
  default     = 1
}