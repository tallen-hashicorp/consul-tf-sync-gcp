output "consul_server_ips" {
  value = [for instance in google_compute_instance.consul_servers : instance.network_interface[0].access_config[0].nat_ip]
  description = "External IP addresses of Nomad server instances"
}