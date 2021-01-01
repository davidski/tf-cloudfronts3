# tf-cloudfronts3

This repository is archived and is no longer maintained.

## Introduction
A Terraform module to easily create an SSL-enabled CloudFront distribution for a custom domain, using an S3 bucket (REST end-point and not using S3 web hosting) as the origin.

Forked off off the Mozilla Community Ops repository. For 
information on Community Ops:
* [Community Ops Wiki Page](https://wiki.mozilla.org/Community_Ops)
* Communication:
  *  IRC: ``#communityit`` on irc.mozilla.org
  *  Discourse: ``https://discourse.mozilla-community.org/c/community-ops``

## Examples
An example which specifies only the required variables:
```
module "example" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "discourse.mozilla-community.org"
  origin_id           = "discoursecdn"
  alias               = "cdn.discourse.mozilla-community.org"
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/00e371ce-a96e-435b-9e76-687ad6sa8231"
}

```
## Reference

variable "project" {}
variable "audit_bucket" {}


| Variable              | Description                                                                                | Required     | Default  |
| -------------          |-------------                                                                               |----------    | ----- |
| `bucket_name` | Name of the S3 bucket to create for content | yes | |
| `project` | Value of the project tag to set for cost-tracking | yes | |
| `audit_bucket` |  S3 bucket name to store CloudFront logs | yes | | 
| `alias`     | The list of one or more alternate domain names for the distribution.                                                | yes          |  |
| `origin_id`              | A unique identifier for the origin.                                                        | yes          |  |
| `acm_certificate_arn`              | The ARN for the ACM cert to use in this distribution.                                                        | yes          |  |
| `price_class` | CloudFront caching price class | No | PriceClass_100 | 
| `ipv6_enabled` | Whether to enable IPv6 | No | true |
| `minimum_protocol_version` | Verison of TLS to enable | no | TLSv1.1-2016 |
| `distribution_enabled`           | Whether the CloudFront Distribution is enabled.  | no           |    `true` |
| `comment`           | A comment to add to the distribution.  | no           |    |
| `default_root_object`           | The object to return when a user requests the root URL.  | no           |  `index.html`  |
| `compression` | Enable CloudFront to compress some files with gzip (and forward the `Accept-Encoding` header to the origin) | no | `false`
