/*
 ------------------------
 | Define our IAM setup |
 ------------------------
*/

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name_prefix        = "iam_for_cloudwatch_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "allow_cloudfront" {
  provider      = aws.east
  statement_id  = "AllowExecutionFromCloudFront"
  action        = "lambda:GetFunction"
  function_name = aws_lambda_function.cloudfront_lambda.function_name
  principal     = "edgelambda.amazonaws.com"
}

/*
 -----------------------
 | Define our function |
 -----------------------
*/

resource "random_id" "function" {
  keepers = {
    # Generate a new id each time we switch to a new project
    ami_id = "${var.project}"
  }

  byte_length = 8
}

data "archive_file" "rewrite" {
  type        = "zip"
  output_path = "${path.module}/.zip/cloudfront.zip"

  source {
    filename = "cloudfront.js"
    content  = file("${path.module}/cloudfront.js")
  }
}

resource "aws_lambda_function" "cloudfront_lambda" {
  provider         = "aws.east"
  filename         = data.archive_file.rewrite.output_path
  source_code_hash = data.archive_file.rewrite.output_base64sha256
  function_name    = "${var.project}_cloudfront_aws_${random_id.function.hex}"
  publish          = true
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "cloudfront.handler"
  runtime          = "nodejs12.x"
  description      = "Cloudfront Lambda@Edge redirects all bare urls to index.html"

  tags {
    managed_by = "Terraform"
    project    = var.project
  }
}
