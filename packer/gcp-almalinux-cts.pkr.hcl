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

source "googlecompute" "almalinux-cts" {
  project_id          = var.gcp_project_id
  region              = var.gcp_region
  zone                = var.gcp_zone
  source_image_family = var.image_family
  machine_type        = "e2-standard-4" #e2-standard-4 , e2-medium
  image_name          = "almalinux-cts{{timestamp}}"
  image_family        = "almalinux-cts"
  disk_size           = 20
  disk_type           = "pd-standard"
  ssh_username        = "packer"
  tags                = ["cts"]
}

build {
  sources = ["source.googlecompute.almalinux-cts"]

  provisioner "file" {
    source = "./packer/configs/consul-client.hcl"
    destination = "/tmp/consul.hcl"
  }

  provisioner "file" {
    source = "./packer/configs/cts-firewall.hcl"
    destination = "/tmp/cts-firewall.hcl"
  }

  provisioner "file" {
    source = "./packer/configs/consul-terraform-sync.service"
    destination = "/tmp/consul-terraform-sync.service"
  }

  provisioner "file" {
    source = "cts-firewall-module"
    destination = "/tmp/"
  }

  provisioner "file" {
    source = "cts-lb-module"
    destination = "/tmp/"
  }

  provisioner "file" {
    source = "./consul.hclic"
    destination = "/tmp/consul.hclic"
  }

  provisioner "shell" {
    script            = "./packer/scripts/provision-consul.sh"
  }

  provisioner "shell" {
    script            = "./packer/scripts/provision-cts.sh"
  }

}
