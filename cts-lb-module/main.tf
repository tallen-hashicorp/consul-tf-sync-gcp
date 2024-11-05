# Filtering services to create firewall rules only for "standalone/nginx"
locals {
  nginx_services = { for k, v in var.services : k => v if v.name == "standalone/nginx" }
}

resource "google_compute_region_backend_service" "consul_backend" {
  name                  = "nginx-backend"
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  region                = "europe-west2"
  health_checks         = [google_compute_region_health_check.consul_hc.self_link]
  backend {
    group          = google_compute_instance_group.consul_instance_group.self_link
    balancing_mode = "CONNECTION"
  }
}

# Create a health check for the backend instances
resource "google_compute_region_health_check" "consul_hc" {
  name = "nginx-health-check"
  tcp_health_check {
    port = 80 # Consul default port
  }
}

# Instance group for Consul servers
resource "google_compute_instance_group" "consul_instance_group" {
  name      = "consul-instance-group"
  zone      = "europe-west2-a" # You might want to set this dynamically as well
  instances = [
    for service in local.nginx_services : "https://www.googleapis.com/compute/v1/projects/${service.value.meta.gcp_project_id}/zones/${service.value.meta.gcp_zone}/instances/${service.value.node}"
  ]
  named_port {
    name = "consul"
    port = 80
  }
}


# external forwarding rule
resource "google_compute_forwarding_rule" "consul_lb" {
  name                  = "consul-internal-lb"
  load_balancing_scheme = "EXTERNAL"
  region                = "europe-west2"
  backend_service       = google_compute_region_backend_service.consul_backend.self_link
  ip_protocol           = "TCP"
  ports                 = ["80"]
}