# -------------------Consul Server-------------------
resource "google_compute_instance" "consul_servers" {
  count         = var.server_instance_count
  name          = "consul-server-${count.index + 1}"
  machine_type  = "e2-medium"
  zone          = "${var.gcp_region}-a"

  tags          = ["consul-server"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.almalinux_consul_server.self_link
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Required to give instances external IPs
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
  count         = var.nginx_instance_count
  name          = "nginx-${count.index + 1}"
  machine_type  = "e2-small"
  zone          = "${var.gcp_region}-a"

  tags          = ["nginx-client"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.almalinux_nginx.self_link
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

# -------------------Data-------------------
data "google_compute_image" "almalinux_consul_server" {
  family  = "almalinux-consul-server"
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
