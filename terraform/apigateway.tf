resource "aws_api_gateway_rest_api" "nlp_api_gw" {
  name        = "nlp_api_gw"
  description = "API Gateway for NLP lambda function"
}


resource "aws_api_gateway_resource" "nlp_api_gw_proxy" {
  rest_api_id = aws_api_gateway_rest_api.nlp_api_gw.id
  parent_id   = aws_api_gateway_rest_api.nlp_api_gw.root_resource_id
  path_part   = "sentiment"
}

resource "aws_api_gateway_method" "nlp_api_gw_method" {
  rest_api_id      = aws_api_gateway_rest_api.nlp_api_gw.id
  resource_id      = aws_api_gateway_resource.nlp_api_gw_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true # this forces the api key to be required
}


resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.nlp_api_gw.id
  resource_id = aws_api_gateway_method.nlp_api_gw_method.resource_id
  http_method = aws_api_gateway_method.nlp_api_gw_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_nlp_lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "nlp_api_gw_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.nlp_api_gw.id
  stage_name  = "test"
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_nlp_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.nlp_api_gw.execution_arn}/*/*"
}


# usage plan and api key
resource "aws_api_gateway_usage_plan" "nlp_usage_plan" {
  name = "nlp_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.nlp_api_gw.id
    stage  = aws_api_gateway_deployment.nlp_api_gw_deployment.stage_name
  }
}

resource "aws_api_gateway_api_key" "nlp_api_key" {
  name = "nlp_api_key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.nlp_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.nlp_usage_plan.id
}