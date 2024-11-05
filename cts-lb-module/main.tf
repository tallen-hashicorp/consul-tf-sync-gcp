# Filtering services to create firewall rules only for "standalone/nginx"
locals {
  nginx_services     = { for k, v in var.services : k => v if v.name == "standalone/nginx" }
  first_service_key  = length(local.nginx_services) > 0 ? keys(local.nginx_services)[0] : null
  gcp_project_id     = local.first_service_key != null ? local.nginx_services[local.first_service_key].meta.gcp_project_id : null
}

provider "google" {
  project = local.gcp_project_id
  region  = "europe-west2"
}

# Backend service that refers to the instance group via data source
resource "google_compute_region_backend_service" "nginx_backend" {
  name                  = "nginx-backend"
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  region                = "europe-west2"
  health_checks         = [google_compute_region_health_check.nginx_hc.self_link]

  dynamic "backend" {
    for_each = length(local.nginx_services) > 0 ? [1] : []
    content {
      group          = data.google_compute_instance_group.nginx_instance_group[0].self_link
      balancing_mode = "CONNECTION"
    }
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
  count     = 1
  name      = "nginx-instance-group"
  zone      = "europe-west2-a"
  
  # This will ensure instances is empty if there are no services
  instances = length(local.nginx_services) > 0 ? [
    for service in local.nginx_services : "https://www.googleapis.com/compute/v1/projects/${service.meta.gcp_project_id}/zones/${service.meta.gcp_zone}/instances/${service.node}"
  ] : []

  named_port {
    name = "nginx"
    port = 80
  }
}

# Data lookup for the instance group to use in the backend
data "google_compute_instance_group" "nginx_instance_group" {
  count = length(local.nginx_services) > 0 ? 1 : 0
  name  = google_compute_instance_group.nginx_instance_group[0].name
  zone  = google_compute_instance_group.nginx_instance_group[0].zone
}



# external forwarding rule
resource "google_compute_forwarding_rule" "nginx_lb" {
  count                 = length(local.nginx_services) > 0 ? 1 : 0
  name                  = "nginx-internal-lb"
  load_balancing_scheme = "EXTERNAL"
  region                = "europe-west2"
  backend_service       = google_compute_region_backend_service.nginx_backend.self_link
  ip_protocol           = "TCP"
  ports                 = ["80"]
}
