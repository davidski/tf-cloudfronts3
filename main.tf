variable "bucket_name" {}
variable "origin_id" {}
variable "alias" {}
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

/*
 ------------------
 | CloudFront OAI |
 ------------------
*/

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.comment}"
}

/*
  ---------------------------
  | CloudFront Distribution |
  ---------------------------
*/

resource "aws_cloudfront_distribution" "ssl_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.cloudfront_bucket.bucket_domain_name}"
    origin_id   = "${var.origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = "${var.distribution_enabled}"
  is_ipv6_enabled     = "${var.ipv6_enabled}"
  comment             = "${var.comment}"
  default_root_object = "${var.default_root_object}"

  aliases     = ["${var.alias}"]
  price_class = "${var.price_class}"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.origin_id}"
    compress         = "${var.compression}"

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${aws_lambda_function.cloudfront_lambda.arn}:latest"
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 360
    max_ttl                = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    bucket = "${var.audit_bucket}.s3.amazonaws.com"
    prefix = "cloudfront/${var.project}"
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "${var.minimum_protocol_version}"
  }

  tags {
    managed_by = "Terraform"
    project    = "${var.project}"
  }
}

/*
  -------------------
  | S3 Bucket Setup |
  -------------------
*/

# configure S3 bucket to host CloudFront presented files
resource "aws_s3_bucket" "cloudfront_bucket" {
  bucket = "${var.bucket_name}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    managed_by = "Terraform"
    project    = "${var.project}"
  }
}

# apply bucket policy to the S3 bucket
resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.cloudfront_bucket.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}

# configure access policy for CloudFront to hit our S3 bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.cloudfront_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.cloudfront_bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}
