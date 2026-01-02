# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0] - 2026-01-02

### Added

- Initial release of the ArvanCloud CDN Load Balancer Terraform Module
- Support for creating load balancers with multiple pools
- Support for configuring origin servers within pools
- Load balancing methods: `failover`, `cluster_rr` (round-robin), `cluster_chash` (consistent hash)
- Pool-level configuration: `method`, `keepalive`, `next_upstream_tcp`, `next_upstream_codes`, `regions`
- Origin-level configuration: `address`, `port`, `weight`, `protocol`, `host_header`
- Input validation for all configuration options
- Basic and advanced usage examples
- Comprehensive documentation

### Security

- Added input validation to prevent invalid configurations
- Region codes validated against 3-letter uppercase format

[v1.0.0]: https://github.com/terraform-r1c-modules/terraform-r1c-cdn-load-balancer/releases/tag/v1.0.0
