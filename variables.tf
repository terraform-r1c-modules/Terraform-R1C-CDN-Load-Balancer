#------------------------------------------------------------------------------
# Required Variables
#------------------------------------------------------------------------------
variable "domain" {
  description = "The domain name to configure the load balancer for"
  type        = string
}

variable "name" {
  description = "Name of the load balancer (alphanumeric and hyphens only)"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+$", var.name))
    error_message = "Load balancer name must contain only alphanumeric characters and hyphens."
  }
}

#------------------------------------------------------------------------------
# Optional Variables - Load Balancer
#------------------------------------------------------------------------------
variable "description" {
  description = "Description of the load balancer"
  type        = string
  default     = ""
}

variable "status" {
  description = "Whether the load balancer is enabled"
  type        = bool
  default     = true
}

variable "method" {
  description = "Load balancing method: failover, cluster_rr (round-robin), or cluster_chash (consistent hash)"
  type        = string
  default     = "failover"

  validation {
    condition     = contains(["failover", "cluster_rr", "cluster_chash"], var.method)
    error_message = "Method must be one of: failover, cluster_rr, cluster_chash."
  }
}

variable "time_slice" {
  description = "Duration for which a pool will uninterruptedly be selected in cluster_rr strategy (e.g., '0s', '30s', '1m')"
  type        = string
  default     = "0s"
}

#------------------------------------------------------------------------------
# Pool Configuration
#------------------------------------------------------------------------------
variable "pools" {
  description = "List of pool configurations with their origins"
  type = list(object({
    name        = string
    description = optional(string)
    status      = optional(bool, true)
    priority    = optional(number, 0)
    method      = optional(string, "cluster_rr")
    keepalive   = optional(string, "off")

    next_upstream_tcp = optional(string, "off")
    next_upstream_tcp_codes = optional(object({
      head    = optional(list(number), [])
      get     = optional(list(number), [])
      post    = optional(list(number), [])
      put     = optional(list(number), [])
      delete  = optional(list(number), [])
      options = optional(list(number), [])
      patch   = optional(list(number), [])
    }))

    regions = optional(list(object({
      id     = string
      region = optional(string)
    })), [])

    origins = optional(list(object({
      name        = string
      address     = string
      port        = optional(number)
      weight      = optional(number, 100)
      status      = optional(bool, true)
      protocol    = optional(string, "auto")
      host_header = optional(string)
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for pool in var.pools : contains(["cluster_rr", "cluster_chash"], pool.method)
    ])
    error_message = "Pool method must be one of: cluster_rr, cluster_chash."
  }

  validation {
    condition = alltrue([
      for pool in var.pools : contains(["on", "off"], pool.keepalive)
    ])
    error_message = "Pool keepalive must be 'on' or 'off'."
  }

  validation {
    condition = alltrue([
      for pool in var.pools : contains(["on", "off"], pool.next_upstream_tcp)
    ])
    error_message = "Pool next_upstream_tcp must be 'on' or 'off'."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.pools : [
        for origin in coalesce(pool.origins, []) : origin.weight >= 1 && origin.weight <= 1000
      ]
    ]))
    error_message = "Origin weight must be between 1 and 1000."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.pools : [
        for origin in coalesce(pool.origins, []) : contains(["auto", "http", "https"], origin.protocol)
      ]
    ]))
    error_message = "Origin protocol must be one of: auto, http, https."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.pools : [
        for origin in coalesce(pool.origins, []) : origin.port == null || (origin.port >= 1 && origin.port <= 65535)
      ]
    ]))
    error_message = "Origin port must be between 1 and 65535."
  }
}
