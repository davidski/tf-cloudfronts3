variable "bucket_name" {}
variable "origin_id" {}

variable "alias" {
  type = list
}

variable "acm_certificate_arn" {}
variable "project" {}
variable "audit_bucket" {}

variable "price_class" {
  default = "PriceClass_100"
}

variable "ipv6_enabled" {
  default = true
}

variable "minimum_protocol_version" {
  default = "TLSv1.1_2016"
}

variable "distribution_enabled" {
  default = true
}

variable "comment" {
  default = ""
}

variable "default_root_object" {
  default = "index.html"
}

variable "compression" {
  default = false
}