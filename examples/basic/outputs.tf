output "load_balancer_id" {
  description = "The ID of the load balancer"
  value       = module.cdn_load_balancer.load_balancer_id
}

output "pool_ids" {
  description = "Map of pool names to their IDs"
  value       = module.cdn_load_balancer.pool_ids
}
