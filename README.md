# ArvanCloud CDN Load Balancer Terraform Module

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4?logo=terraform)
![Version](https://img.shields.io/github/v/release/terraform-r1c-modules/terraform-r1c-cdn-load-balancer?logo=github&color=red&label=Version)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

This Terraform module provisions and manages Load Balancer resources for ArvanCloud CDN, including pools with multiple origin servers.

## Requirements

| Name                                                                             | Version  |
| -------------------------------------------------------------------------------- | -------- |
| [terraform](https://developer.hashicorp.com/terraform)                           | >= 1.5   |
| [arvancloud](https://git.arvancloud.ir/arvancloud/terraform-provider-arvancloud) | >= 0.2.2 |

## Usage

### Basic Example

```hcl
module "cdn_load_balancer" {
  source = "git@github.com:terraform-r1c-modules/Terraform-R1C-CDN-Load-Balancer.git?ref=main"

  domain      = "example.ir"
  name        = "my-load-balancer"
  description = "Production load balancer"
  method      = "failover"

  pools = [
    {
      name        = "primary-pool"
      description = "Primary origin pool"
      priority    = 0
      status      = true
      method      = "cluster_rr"
      regions     = ["ir"]

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
    },
    {
      name        = "backup-pool"
      description = "Backup origin pool"
      priority    = 1
      status      = true
      regions     = ["ir"]

      origins = [
        {
          name     = "backup-origin"
          address  = "185.23.45.200"
          port     = 443
          weight   = 100
          protocol = "https"
        }
      ]
    }
  ]
}
```

### Advanced Example with Upstream Retry

```hcl
module "cdn_load_balancer" {
  source = "git@github.com:terraform-r1c-modules/Terraform-R1C-CDN-Load-Balancer.git?ref=main"

  domain      = "example.ir"
  name        = "advanced-lb"
  description = "Advanced load balancer with retry"
  method      = "cluster_rr"
  time_slice  = "30s"

  pools = [
    {
      name              = "api-pool"
      description       = "API origin pool"
      priority          = 0
      method            = "cluster_chash"
      keepalive         = "on"
      next_upstream_tcp = "on"
      regions           = ["ir", "eu"]

      origins = [
        {
          name        = "api-origin-1"
          address     = "10.0.1.10"
          port        = 8080
          weight      = 200
          protocol    = "https"
          host_header = "api.example.ir"
        },
        {
          name        = "api-origin-2"
          address     = "10.0.1.11"
          port        = 8080
          weight      = 100
          protocol    = "https"
          host_header = "api.example.ir"
        }
      ]
    }
  ]
}
```

## Resources

| Name                                                   | Type     |
| ------------------------------------------------------ | -------- |
| `arvancloud_cdn_domain_load_balancer.this`             | Resource |
| `arvancloud_cdn_domain_load_balancer_pool.this`        | Resource |
| `arvancloud_cdn_domain_load_balancer_pool_origin.this` | Resource |

## Inputs

| Name          | Description                                                   | Type           | Default    | Required |
| ------------- | ------------------------------------------------------------- | -------------- | ---------- | :------: |
| `domain`      | The domain name to configure the load balancer for            | `string`       | N/A        |   Yes    |
| `name`        | Name of the load balancer (alphanumeric and hyphens only)     | `string`       | N/A        |   Yes    |
| `description` | Description of the load balancer                              | `string`       | `""`       |    No    |
| `status`      | Whether the load balancer is enabled                          | `bool`         | `true`     |    No    |
| `method`      | Load balancing method: failover, cluster_rr, or cluster_chash | `string`       | `failover` |    No    |
| `time_slice`  | Duration for pool selection in cluster_rr strategy            | `string`       | `0s`       |    No    |
| `pools`       | List of pool configurations with their origins                | `list(object)` | `[]`       |    No    |

### Pool Object Structure

| Name                | Description                              | Type           | Default      | Required |
| ------------------- | ---------------------------------------- | -------------- | ------------ | :------: |
| `name`              | Pool name                                | `string`       | N/A          |   Yes    |
| `description`       | Pool description                         | `string`       | `null`       |    No    |
| `status`            | Pool enabled status                      | `bool`         | `true`       |    No    |
| `priority`          | Pool priority (0 = default)              | `number`       | `0`          |    No    |
| `method`            | Pool method: cluster_rr or cluster_chash | `string`       | `cluster_rr` |    No    |
| `keepalive`         | Keepalive setting: on or off             | `string`       | `off`        |    No    |
| `next_upstream_tcp` | Try next upstream on failure             | `string`       | `off`        |    No    |
| `regions`           | List of region identifiers               | `list(string)` | N/A          |   Yes    |
| `origins`           | List of origin configurations            | `list(object)` | `[]`         |    No    |

### Origin Object Structure

| Name          | Description                           | Type     | Default | Required |
| ------------- | ------------------------------------- | -------- | ------- | :------: |
| `name`        | Origin name                           | `string` | N/A     |   Yes    |
| `address`     | Origin address (IP or hostname)       | `string` | N/A     |   Yes    |
| `port`        | Origin port (1-65535)                 | `number` | `null`  |    No    |
| `weight`      | Origin weight (1-1000)                | `number` | `100`   |    No    |
| `status`      | Origin enabled status                 | `bool`   | `true`  |    No    |
| `protocol`    | Origin protocol: auto, http, or https | `string` | `auto`  |    No    |
| `host_header` | Custom host header for the origin     | `string` | `null`  |    No    |

## Outputs

| Name                 | Description                         |
| -------------------- | ----------------------------------- |
| `load_balancer_id`   | The ID of the load balancer         |
| `load_balancer_name` | The name of the load balancer       |
| `load_balancer`      | The complete load balancer resource |
| `pool_ids`           | Map of pool names to their IDs      |
| `pools`              | Map of all pool resources           |
| `origin_ids`         | Map of origin keys to their IDs     |
| `origins`            | Map of all origin resources         |

## Load Balancing Methods

- **failover**: Routes traffic to the first healthy pool; falls back to lower priority pools when primary fails
- **cluster_rr** (Round Robin): Distributes traffic evenly across all healthy pools
- **cluster_chash** (Consistent Hash): Routes requests to the same pool based on request characteristics

## License

MIT License - See [LICENSE](LICENSE) for details.
