module "cdn_load_balancer" {
  source = "../../"

  domain      = var.domain
  name        = "basic-lb"
  description = "Basic load balancer example"
  method      = "failover"

  pools = [
    {
      name        = "primary-pool"
      description = "Primary origin pool"
      priority    = 0
      status      = true
      regions     = ["THR"] # 3-letter region code (e.g., THR for Tehran)

      origins = [
        {
          name     = "origin-1"
          address  = "185.23.45.100"
          port     = 443
          weight   = 100
          protocol = "https"
        },
        {
          name     = "origin-2"
          address  = "185.23.45.101"
          port     = 443
          weight   = 100
          protocol = "https"
        }
      ]
    }
  ]
}
