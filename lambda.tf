resource "aws_iam_role" "pokemon_api_role" {
  name = "pokemon_api_role"

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

data "archive_file" "pokemon_zip" {
  type        = "zip"
  source_file = "templates/lambda/pokemon_lambda.py"
  output_path = "templates/lambda/builds/pokemon_lambda.zip"
}

resource "aws_lambda_function" "pokemon_lambda_function" {
  filename         = data.archive_file.pokemon_zip.output_path
  function_name    = "pokemon_api"
  description      = "Restful API Endpoint returning attributes of 5 of my favorite pokemon"
  handler          = "pokemon_lambda.lambda_handler"
  source_code_hash = data.archive_file.pokemon_zip.output_base64sha256
  runtime          = "python3.8"
  role             = aws_iam_role.pokemon_api_role.arn
  timeout          = 6
}

