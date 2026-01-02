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

      origins = [
        {
          name     = "origin-1"
          address  = "origin1.example.ir"
          port     = 443
          weight   = 100
          protocol = "https"
        },
        {
          name     = "origin-2"
          address  = "origin2.example.ir"
          port     = 443
          weight   = 100
          protocol = "https"
        }
      ]
    }
  ]
}
