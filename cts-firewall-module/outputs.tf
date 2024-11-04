output "consul_services" {
  description = "Details of all Consul services monitored by Consul-Terraform-Sync"
  value = {
    for service_key, service in var.services : service_key => {
      id                  = service.id
      name                = service.name
      kind                = service.kind
      address             = service.address
      port                = service.port
      meta                = service.meta
      tags                = service.tags
      namespace           = service.namespace
      status              = service.status
      node                = service.node
      node_id             = service.node_id
      node_address        = service.node_address
      node_datacenter     = service.node_datacenter
      node_tagged_addresses = service.node_tagged_addresses
      node_meta           = service.node_meta
      cts_user_defined_meta = service.cts_user_defined_meta
    }
  }
}
