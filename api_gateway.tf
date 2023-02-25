resource "aws_api_gateway_rest_api" "pokemon_api" {
  name        = "pokemon-api" # Set the desired API name here
  description = "REST API for Pokemon data"
}

resource "aws_api_gateway_resource" "pokemon" {
  rest_api_id = aws_api_gateway_rest_api.pokemon_api.id
  parent_id   = aws_api_gateway_rest_api.pokemon_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "get_pokemon" {
  rest_api_id   = aws_api_gateway_rest_api.pokemon_api.id
  resource_id   = aws_api_gateway_resource.pokemon.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.pokemon_api.id
  resource_id   = aws_api_gateway_rest_api.pokemon_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "pokemon_integration" {
  rest_api_id = aws_api_gateway_rest_api.pokemon_api.id
  resource_id = aws_api_gateway_resource.pokemon.id
  http_method = aws_api_gateway_method.get_pokemon.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.pokemon_lambda_function.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.pokemon_api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.pokemon_lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "pokemon_api" {
  rest_api_id = aws_api_gateway_rest_api.pokemon_api.id
  stage_name  = "prod"
  depends_on = [
    aws_api_gateway_method.get_pokemon,
    aws_api_gateway_integration.pokemon_integration,
    aws_api_gateway_integration.lambda_root
  ]
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pokemon_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.pokemon_api.execution_arn}/*/*/*"
}
