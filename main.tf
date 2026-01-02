#------------------------------------------------------------------------------
# Load Balancer Resource
#------------------------------------------------------------------------------
resource "arvancloud_cdn_domain_load_balancer" "this" {
  domain      = var.domain
  name        = var.name
  description = var.description
  status      = var.status
  method      = var.method
  time_slice  = var.time_slice
}

#------------------------------------------------------------------------------
# Load Balancer Pools
#------------------------------------------------------------------------------
resource "arvancloud_cdn_domain_load_balancer_pool" "this" {
  for_each = { for pool in var.pools : pool.name => pool }

  domain        = var.domain
  load_balancer = arvancloud_cdn_domain_load_balancer.this.id
  name          = each.value.name
  description   = lookup(each.value, "description", null)
  status        = lookup(each.value, "status", true)
  priority      = lookup(each.value, "priority", 0)
  method        = lookup(each.value, "method", "cluster_rr")
  keepalive     = lookup(each.value, "keepalive", "off")

  next_upstream_tcp   = lookup(each.value, "next_upstream_tcp", "off")
  next_upstream_codes = lookup(each.value, "next_upstream_codes", {})
  regions             = lookup(each.value, "regions", [])
}

#------------------------------------------------------------------------------
# Load Balancer Pool Origins
#------------------------------------------------------------------------------
locals {
  # Flatten pools and their origins into a single list for iteration
  pool_origins = flatten([
    for pool in var.pools : [
      for origin in lookup(pool, "origins", []) : {
        pool_name   = pool.name
        origin_name = origin.name
        origin      = origin
      }
    ]
  ])
}

resource "arvancloud_cdn_domain_load_balancer_pool_origin" "this" {
  for_each = { for po in local.pool_origins : "${po.pool_name}-${po.origin_name}" => po }

  domain        = var.domain
  load_balancer = arvancloud_cdn_domain_load_balancer.this.id
  pool          = arvancloud_cdn_domain_load_balancer_pool.this[each.value.pool_name].id
  name          = each.value.origin.name
  address       = each.value.origin.address
  port          = lookup(each.value.origin, "port", null)
  weight        = lookup(each.value.origin, "weight", 100)
  status        = lookup(each.value.origin, "status", true)
  protocol      = lookup(each.value.origin, "protocol", "auto")
  host_header   = lookup(each.value.origin, "host_header", null)
}
