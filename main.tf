#------------------------------------------------------------------------------
# Load Balancer Resource
#------------------------------------------------------------------------------
resource "arvancloud_cdn_load_balancer" "this" {
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
resource "arvancloud_cdn_load_balancer_pool" "this" {
  for_each = { for pool in var.pools : pool.name => pool }

  domain           = var.domain
  load_balancer_id = arvancloud_cdn_load_balancer.this.id
  name             = each.value.name
  description      = lookup(each.value, "description", null)
  status           = lookup(each.value, "status", true)
  priority         = lookup(each.value, "priority", 0)
  method           = lookup(each.value, "method", "cluster_rr")
  keepalive        = lookup(each.value, "keepalive", "off")

  next_upstream_tcp = lookup(each.value, "next_upstream_tcp", "off")

  dynamic "next_upstream_tcp_codes" {
    for_each = lookup(each.value, "next_upstream_tcp_codes", null) != null ? [each.value.next_upstream_tcp_codes] : []
    content {
      head    = lookup(next_upstream_tcp_codes.value, "head", [])
      get     = lookup(next_upstream_tcp_codes.value, "get", [])
      post    = lookup(next_upstream_tcp_codes.value, "post", [])
      put     = lookup(next_upstream_tcp_codes.value, "put", [])
      delete  = lookup(next_upstream_tcp_codes.value, "delete", [])
      options = lookup(next_upstream_tcp_codes.value, "options", [])
      patch   = lookup(next_upstream_tcp_codes.value, "patch", [])
    }
  }

  dynamic "regions" {
    for_each = lookup(each.value, "regions", [])
    content {
      id     = regions.value.id
      region = lookup(regions.value, "region", null)
    }
  }
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

resource "arvancloud_cdn_load_balancer_pool_origin" "this" {
  for_each = { for po in local.pool_origins : "${po.pool_name}-${po.origin_name}" => po }

  domain           = var.domain
  load_balancer_id = arvancloud_cdn_load_balancer.this.id
  pool_id          = arvancloud_cdn_load_balancer_pool.this[each.value.pool_name].id
  name             = each.value.origin.name
  address          = each.value.origin.address
  port             = lookup(each.value.origin, "port", null)
  weight           = lookup(each.value.origin, "weight", 100)
  status           = lookup(each.value.origin, "status", true)
  protocol         = lookup(each.value.origin, "protocol", "auto")
  host_header      = lookup(each.value.origin, "host_header", null)
}
