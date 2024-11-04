log_level   = "INFO"
working_dir = "sync-tasks"
port        = 8558
id          = "cts-firewall"

buffer_period {
  enabled = true
  min     = "5s"
  max     = "20s"
}

license {
  path = "/etc/consul.d/license.hclic"
  auto_retrieval {
    enabled = false
  }
}

consul {
  address = "127.0.0.1:8500"
  service_registration {
    service_name = "cts"
    default_check {
      address = "http://localhost:8558"
    }
  }
}

driver "terraform" {
  log         = false

  backend "consul" {
    gzip = true
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 6.10.0"
    }
  }
}

task {
  name      = "firewall"
  description = "add firewall changes for every nginx node"
  module    = "/opt/cts-firewall-module"
  providers = ["google"]

  condition "services" {
    names = ["standalone/nginx"]
    use_as_module_input = true
  }

  module_input "consul-kv" {
    path       = "gcp_project_id"
    recurse    = false
  }
}