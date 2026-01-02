#------------------------------------------------------------------------------
# Load Balancer Outputs
#------------------------------------------------------------------------------
output "load_balancer_id" {
  description = "The ID of the load balancer"
  value       = arvancloud_cdn_load_balancer.this.id
}

output "load_balancer_name" {
  description = "The name of the load balancer"
  value       = arvancloud_cdn_load_balancer.this.name
}

output "load_balancer" {
  description = "The complete load balancer resource"
  value       = arvancloud_cdn_load_balancer.this
}

#------------------------------------------------------------------------------
# Pool Outputs
#------------------------------------------------------------------------------
output "pool_ids" {
  description = "Map of pool names to their IDs"
  value       = { for k, v in arvancloud_cdn_load_balancer_pool.this : k => v.id }
}

output "pools" {
  description = "Map of all pool resources"
  value       = arvancloud_cdn_load_balancer_pool.this
}

#------------------------------------------------------------------------------
# Origin Outputs
#------------------------------------------------------------------------------
output "origin_ids" {
  description = "Map of origin keys (pool_name-origin_name) to their IDs"
  value       = { for k, v in arvancloud_cdn_load_balancer_pool_origin.this : k => v.id }
}

output "origins" {
  description = "Map of all origin resources"
  value       = arvancloud_cdn_load_balancer_pool_origin.this
}
