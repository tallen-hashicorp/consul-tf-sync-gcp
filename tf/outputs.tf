output "external_lb_ip" {
  description = "The external IP address of the load balancer"
  value       = google_compute_forwarding_rule.consul_lb.ip_address
}
