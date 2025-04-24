# API Gateway for proxying requests to MediaWiki with Cognito auth

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/api-gateway/${var.project_name}"
  retention_in_days = 7
}

resource "aws_api_gateway_rest_api" "wiki_api" {
  name        = "${var.project_name}-wiki-api"
  description = "API Gateway protecting MediaWiki edits with Cognito"
}

resource "aws_api_gateway_authorizer" "wiki_auth" {
  name            = "${var.project_name}-wiki-auth"
  rest_api_id     = aws_api_gateway_rest_api.wiki_api.id
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.main.arn]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.wiki_api.id
  parent_id   = aws_api_gateway_rest_api.wiki_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_get" {
  rest_api_id   = aws_api_gateway_rest_api.wiki_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "proxy_post" {
  rest_api_id   = aws_api_gateway_rest_api.wiki_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.wiki_auth.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "proxy_put" {
  rest_api_id   = aws_api_gateway_rest_api.wiki_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.wiki_auth.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "proxy_delete" {
  rest_api_id   = aws_api_gateway_rest_api.wiki_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.wiki_auth.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy_get" {
  rest_api_id             = aws_api_gateway_rest_api.wiki_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.main.dns_name}/{proxy}"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "proxy_post" {
  rest_api_id             = aws_api_gateway_rest_api.wiki_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.main.dns_name}/{proxy}"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "proxy_put" {
  rest_api_id             = aws_api_gateway_rest_api.wiki_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_put.http_method
  integration_http_method = "PUT"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.main.dns_name}/{proxy}"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "proxy_delete" {
  rest_api_id             = aws_api_gateway_rest_api.wiki_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_delete.http_method
  integration_http_method = "DELETE"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.main.dns_name}/{proxy}"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "wiki_deploy" {
  rest_api_id = aws_api_gateway_rest_api.wiki_api.id

  depends_on = [
    aws_api_gateway_method.proxy_get,
    aws_api_gateway_method.proxy_post,
    aws_api_gateway_method.proxy_put,
    aws_api_gateway_method.proxy_delete,
    aws_api_gateway_integration.proxy_get,
    aws_api_gateway_integration.proxy_post,
    aws_api_gateway_integration.proxy_put,
    aws_api_gateway_integration.proxy_delete,
  ]
}

resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.wiki_api.id
  deployment_id = aws_api_gateway_deployment.wiki_deploy.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      requestId         = "$context.requestId",
      requestTime       = "$context.requestTime",
      httpMethod        = "$context.httpMethod",
      resourcePath      = "$context.resourcePath",
      status            = "$context.status",
      responseLength    = "$context.responseLength",
      integrationStatus = "$context.integrationStatus",
      user              = "$context.identity.user"
    })
  }

  xray_tracing_enabled = true

  tags = {
    Name        = "${var.project_name}-gateway-stage"
    Environment = var.environment
  }
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch.arn
}
