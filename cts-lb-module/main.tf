# Filtering services to create firewall rules only for "standalone/nginx"
locals {
  nginx_services = { for k, v in var.services : k => v if v.name == "standalone/nginx" }
  first_service_key = keys(local.nginx_services)[0]  # Get the first key
  gcp_project_id = local.nginx_services[local.first_service_key].meta.gcp_project_id  # Get the meta.gcp_project_id
}

provider "google" {
  project = local.gcp_project_id
  region  = "europe-west2"
}

resource "google_compute_region_backend_service" "nginx_backend" {
  name                  = "nginx-backend"
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  region                = "europe-west2"
  health_checks         = [google_compute_region_health_check.nginx_hc.self_link]
  backend {
    group          = google_compute_instance_group.nginx_instance_group.self_link
    balancing_mode = "CONNECTION"
  }
}

# Create a health check for the backend instances
resource "google_compute_region_health_check" "nginx_hc" {
  name = "nginx-health-check"
  tcp_health_check {
    port = 80 
  }
}

# Instance group for Nginx servers
resource "google_compute_instance_group" "nginx_instance_group" {
  name      = "nginx-instance-group"
  zone      = "europe-west2-a" # You might want to set this dynamically as well
  instances = [
    for service in local.nginx_services : "https://www.googleapis.com/compute/v1/projects/${service.meta.gcp_project_id}/zones/${service.meta.gcp_zone}/instances/${service.node}"
  ]
  named_port {
    name = "nginx"
    port = 80
  }
}


# external forwarding rule
resource "google_compute_forwarding_rule" "nginx_lb" {
  name                  = "nginx-internal-lb"
  load_balancing_scheme = "EXTERNAL"
  region                = "europe-west2"
  backend_service       = google_compute_region_backend_service.nginx_backend.self_link
  ip_protocol           = "TCP"
  ports                 = ["80"]
}