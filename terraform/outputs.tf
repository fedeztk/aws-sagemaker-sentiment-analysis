output "api_gw_invoke_url" {
  value = aws_api_gateway_deployment.nlp_api_gw_deployment.invoke_url
}

output "api_gw_resource_paths" {
  value = aws_api_gateway_resource.nlp_api_gw_proxy.path
}

output "api_gw_api_key" {
  value = aws_api_gateway_api_key.nlp_api_key.name
}