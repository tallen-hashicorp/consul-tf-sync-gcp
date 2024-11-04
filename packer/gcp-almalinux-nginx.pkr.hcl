packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west2"
}

variable "gcp_zone" {
  type    = string
  default = "europe-west2-a"
}

variable "image_family" {
  type    = string
  default = "almalinux-8"
}

source "googlecompute" "almalinux-nginx" {
  project_id          = var.gcp_project_id
  region              = var.gcp_region
  zone                = var.gcp_zone
  source_image_family = var.image_family
  machine_type        = "e2-standard-4"
  image_name          = "almalinux-nginx{{timestamp}}"
  image_family        = "almalinux-nginx"
  disk_size           = 20
  disk_type           = "pd-standard"
  ssh_username        = "packer"
  tags                = ["nginx"]
}

build {
  sources = ["source.googlecompute.almalinux-nginx"]

  provisioner "file" {
    source = "./packer/configs/consul-nginx.hcl"
    destination = "/tmp/consul.hcl"
  }

  provisioner "file" {
    source = "./consul.hclic"
    destination = "/tmp/consul.hclic"
  }

  provisioner "shell" {
    script            = "./packer/scripts/provision-consul.sh"
  }

  provisioner "shell" {
    script            = "./packer/scripts/provision-nginx.sh"
  }

}
