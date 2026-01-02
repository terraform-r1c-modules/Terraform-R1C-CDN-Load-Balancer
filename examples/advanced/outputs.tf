output "load_balancer" {
  description = "Complete load balancer resource"
  value       = module.cdn_load_balancer.load_balancer
}

output "load_balancer_id" {
  description = "The ID of the load balancer"
  value       = module.cdn_load_balancer.load_balancer_id
}

output "pools" {
  description = "All pool resources"
  value       = module.cdn_load_balancer.pools
}

output "pool_ids" {
  description = "Map of pool names to their IDs"
  value       = module.cdn_load_balancer.pool_ids
}

output "origins" {
  description = "All origin resources"
  value       = module.cdn_load_balancer.origins
}

output "origin_ids" {
  description = "Map of origin keys to their IDs"
  value       = module.cdn_load_balancer.origin_ids
}
