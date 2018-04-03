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

resource "aws_lambda_function" "cloudfront_lambda" {
  filename         = "cloudfront.js"
  function_name    = "cloudfront_aws"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "exports.handler"
  source_code_hash = "${base64sha256(file("cloudfront.js"))}"
  runtime          = "nodejs6.10"

  tags {
    managed_by = "Terraform"
    project    = "${var.project}"
  }
}
