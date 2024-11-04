# -------------------Consul Server-------------------
resource "google_compute_instance" "consul_servers" {
  count        = var.server_instance_count
  name         = "consul-server-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = "${var.gcp_region}-a"

  tags = ["consul-server"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.almalinux_consul_server.self_link
      size  = 20
    }
  }

  network_interface {
    network = "default"
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# -------------------Consul LB---------------
# Create a backend service
resource "google_compute_region_backend_service" "consul_backend" {
  name                  = "consul-backend"
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
  name = "consul-health-check"
  tcp_health_check {
    port = 8500 # Consul default port
  }
}

# Instance group for Consul servers
resource "google_compute_instance_group" "consul_instance_group" {
  name      = "consul-instance-group"
  zone      = "${var.gcp_region}-a"
  instances = [for instance in google_compute_instance.consul_servers : instance.self_link]
  named_port {
    name = "consul"
    port = 8500
  }
}

# external forwarding rule
resource "google_compute_forwarding_rule" "consul_lb" {
  name                  = "consul-internal-lb"
  load_balancing_scheme = "EXTERNAL"
  region                = "europe-west2"
  backend_service       = google_compute_region_backend_service.consul_backend.self_link
  ip_protocol           = "TCP"
  ports                 = ["8500"]
}

# -------------------CTS Server-------------------
resource "google_compute_instance" "cts_servers" {
  count        = var.cts_instance_count
  name         = "cts-server-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = "${var.gcp_region}-a"

  tags = ["cts-server"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.almalinux_cts.self_link
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Required to give instances external IPs #8
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# -------------------Nginx-------------------

resource "google_compute_instance" "nginx_server" {
  count        = var.nginx_instance_count
  name         = "nginx-${count.index + 1}"
  machine_type = "e2-small"
  zone         = "${var.gcp_region}-a"

  tags = ["nginx"] # For the Firewall demo to work this needs to match Consul's tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.almalinux_nginx.self_link
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Required to give instances external IPs #8
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# -------------------Data-------------------
data "google_compute_image" "almalinux_consul_server" {
  family  = "almalinux-consul-server"
  project = var.gcp_project_id
}

data "google_compute_image" "almalinux_cts" {
  family  = "almalinux-cts"
  project = var.gcp_project_id
}

data "google_compute_image" "almalinux_nginx" {
  family  = "almalinux-nginx"
  project = var.gcp_project_id
}


# -------------------Firewall Rule-------------------
resource "google_compute_firewall" "consul_firewall" {
  name    = "consul-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8500"]
  }

  source_ranges = ["0.0.0.0/0"] # Adjust this if you want to restrict access to specific IP ranges

  target_tags = ["consul-server"]
}

# -------------------DNS for Consul CTS-------------------
# This is not required but nice to have
resource "google_dns_managed_zone" "my_zone" {
  name       = "consul-zone"
  dns_name   = "consul.internal."
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "projects/${var.gcp_project_id}/global/networks/default"
    }
  }
}

# consul-servers.consul.internal
resource "google_dns_record_set" "consul_servers" {
  name         = "consul-servers.consul.internal."
  managed_zone = google_dns_managed_zone.my_zone.name
  type         = "A"
  ttl          = 300

  # Collect all internal IP addresses of the Consul servers
  rrdatas = [
    for instance in google_compute_instance.consul_servers :
    instance.network_interface[0].network_ip
  ]
}

# -------------------Consul KV for Project ID-------------------
# This is used to store the project ID in Consul and picked up by CTS
provider "consul" {
  address    = "${google_compute_forwarding_rule.consul_lb.ip_address}:8500"
}

resource "consul_keys" "gcp_project_id" {
  # Set the CNAME of our load balancer as a key
  key {
    path  = "gcp_project_id"
    value = "${var.gcp_project_id}"
  }
}