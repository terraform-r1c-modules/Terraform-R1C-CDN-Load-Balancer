module "cdn_load_balancer" {
  source = "../../"

  domain      = var.domain
  name        = "advanced-lb"
  description = "Advanced load balancer with multiple pools and retry logic"
  status      = true
  method      = "failover"
  time_slice  = "30s"

  pools = [
    # Primary pool with consistent hashing
    {
      name              = "primary-api-pool"
      description       = "Primary API origin pool with consistent hashing"
      priority          = 0
      status            = true
      method            = "cluster_chash"
      keepalive         = "on"
      next_upstream_tcp = "on"

      next_upstream_tcp_codes = {
        get  = [502, 503, 504]
        post = [502, 503]
        put  = [502, 503]
      }

      origins = [
        {
          name        = "api-server-1"
          address     = "api1.example.ir"
          port        = 8080
          weight      = 200
          status      = true
          protocol    = "https"
          host_header = "api.example.ir"
        },
        {
          name        = "api-server-2"
          address     = "api2.example.ir"
          port        = 8080
          weight      = 200
          status      = true
          protocol    = "https"
          host_header = "api.example.ir"
        },
        {
          name        = "api-server-3"
          address     = "api3.example.ir"
          port        = 8080
          weight      = 100
          status      = true
          protocol    = "https"
          host_header = "api.example.ir"
        }
      ]
    },

    # Backup pool with round-robin
    {
      name              = "backup-pool"
      description       = "Backup pool for failover"
      priority          = 1
      status            = true
      method            = "cluster_rr"
      keepalive         = "off"
      next_upstream_tcp = "on"

      next_upstream_tcp_codes = {
        get  = [500, 502, 503, 504]
        post = [502, 503, 504]
      }

      origins = [
        {
          name        = "backup-server-1"
          address     = "backup1.example.ir"
          port        = 443
          weight      = 100
          status      = true
          protocol    = "https"
          host_header = "backup.example.ir"
        },
        {
          name        = "backup-server-2"
          address     = "backup2.example.ir"
          port        = 443
          weight      = 100
          status      = true
          protocol    = "https"
          host_header = "backup.example.ir"
        }
      ]
    }
  ]
}
