resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_cloudfront" {
  statement_id  = "AllowExecutionFromCloudFront"
  action        = "lambda:GetFunction"
  function_name = "${aws_lambda_function.cloudfront_lambda.function_name}"
  principal     = "edgelambda.amazonaws.com"
}

resource "aws_lambda_function" "cloudfront_lambda" {
  provider         = "aws.east"
  filename         = "${path.module}/cloudfront.zip"
  function_name    = "cloudfront_aws"
  publish          = true
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "exports.handler"
  source_code_hash = "${base64sha256(file("${path.module}/cloudfront.zip"))}"
  runtime          = "nodejs6.10"
  description      = "Cloudfront Lambda@Edge redirects all bare urls to index.html"

  tags {
    managed_by = "Terraform"
    project    = "${var.project}"
  }
}
