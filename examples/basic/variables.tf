variable "arvancloud_api_key" {
  description = "ArvanCloud API key for authentication"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "The domain name to configure the load balancer for"
  type        = string
}
