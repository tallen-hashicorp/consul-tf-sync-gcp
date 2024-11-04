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
    enabled = true
  }
}

consul {
  address = "consul-servers.consul.local:8500"
  service_registration {
    service_name = "cts"
    default_check {
      address = "http://localhost:8558"
    }
  }
}