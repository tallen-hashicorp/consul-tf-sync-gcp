provider "google" {
  project = var.gcp_project_id
}

# Filtering services to create firewall rules only for "standalone/nginx"
locals {
  nginx_services = { for k, v in var.services : k => v if v.name == "standalone/nginx" }
}

resource "google_compute_firewall" "nginx_service_firewalls" {
  for_each = local.nginx_services

  name    = "firewall-${each.value.node}"
  network = "default" # Replace with your network if it's not "default"

  allow {
    protocol = "tcp"
    ports    = [each.value.port == 80 ? "80" : "default"]
  }

  # Target tags retrieved from each service's tags in Consul
  target_tags = each.value.tags

  # For the demo allow all
  source_ranges = ["0.0.0.0/0"]

  # Optional description for context in GCP console
  description = "Firewall rule for ${each.value.name} with address ${each.value.address} on port 80"
}
