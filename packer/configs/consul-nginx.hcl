datacenter              = "nomad"

data_dir                = "/opt/consul"

bind_addr               = "0.0.0.0" # the default
client_addr             = "0.0.0.0"

log_level               = "INFO"
log_file                = "/var/log/"
log_rotate_duration     = "24h"
log_rotate_max_files    = 5

server                  = false

retry_join              = ["provider=gce tag_value=consul-server"]

license_path            = "/etc/consul.d/license.hclic"

telemetry {
    prometheus_retention_time   = "480h"
    disable_hostname            = true
}

service {
    name = "standalone/nginx"
    port = 80
    tags = ["nginx"]
    check {
        http = "http://localhost:80/index.html"
        interval = "10s"
        timeout = "1s"
    }
    meta = {
        gcp_project_id = ""
    }
}