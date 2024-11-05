log_level   = "INFO"
working_dir = "/etc/cts/sync-tasks"
port        = 8558
id          = "cts-firewall"

buffer_period {
  enabled = true
  min     = "5s"
  max     = "20s"
}

syslog {
  enabled  = true
  name     = "consul-terraform-sync"
  facility = "local0"
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
}

task {
  name      = "lb"
  description = "add lb changes for every nginx node"
  module    = "/opt/cts-lb-module"
  providers = ["google"]

  condition "services" {
    names = ["standalone/nginx"]
    use_as_module_input = true
  }
}