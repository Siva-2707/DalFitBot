variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region     = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "fastapi-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "private-subnet" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-fastapi-sg"
  description = "Allow HTTP from NLB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_instance" "fastapi_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update packages
              yum update -y

              # Enable Docker and install necessary packages
              amazon-linux-extras enable docker
              yum install -y docker git

              # Start Docker and add ec2-user to docker group
              service docker start
              usermod -aG docker ec2-user

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
                -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Run as ec2-user
              sudo -u ec2-user bash -c '
                cd /home/ec2-user

                if [ ! -d app ]; then
                  git clone https://github.com/Siva-2707/DalFitBot.git app
                fi

                cd app/backend

                docker-compose up -d
              '
              EOF

  tags = {
    Name = "fastapi-ec2"
  }
}

resource "aws_lb" "nlb" {
  name               = "fastapi-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public.id]
}

resource "aws_lb_target_group" "tg" {
  name        = "fastapi-tg"
  port        = 8080
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.fastapi_ec2.id
  port             = 8080
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "fastapi-vpc-link"
  subnet_ids         = [aws_subnet.public.id]
  security_group_ids = [aws_security_group.ec2_sg.id]
}

# resource "aws_apigatewayv2_api" "http_api" {
#   name          = "fastapi-http-api"
#   protocol_type = "HTTP"
# }

# resource "aws_apigatewayv2_integration" "http_integration" {
#   api_id                 = aws_apigatewayv2_api.http_api.id
#   integration_type       = "HTTP_PROXY"
#   integration_uri        = aws_lb_listener.nlb_listener.arn
#   integration_method     = "ANY"
#   connection_type        = "VPC_LINK"
#   connection_id          = aws_apigatewayv2_vpc_link.vpc_link.id
#   payload_format_version = "1.0"
# }

# resource "aws_apigatewayv2_route" "http_route" {
#   api_id    = aws_apigatewayv2_api.http_api.id
#   route_key = "ANY /{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.http_integration.id}"
# }

# resource "aws_apigatewayv2_stage" "http_stage" {
#   api_id      = aws_apigatewayv2_api.http_api.id
#   name        = "$default"
#   auto_deploy = true
# }

resource "aws_cognito_user_pool" "chat_user_pool" {
  name = "chat-app-user-pool"
  username_attributes = ["email"]  # Use email as the username

  auto_verified_attributes = ["email"]  # ✅ Enables email verification

  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true      # ✅ Email is required
    developer_only_attribute = false
    mutable                  = true
    string_attribute_constraints {
      min_length = 5
      max_length = 50
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Verify your email for MyApp"
    email_message        = "Your verification code is {####}"
  }

  mfa_configuration = "OFF"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_domain" "my_domain" {
  domain       = "dalfitbot-auth"
  user_pool_id = aws_cognito_user_pool.chat_user_pool.id
}

resource "aws_cognito_user_pool_client" "chat_client" {
  name                          = "chat-app-client"
  user_pool_id                  = aws_cognito_user_pool.chat_user_pool.id
  generate_secret               = false
  explicit_auth_flows           = [ "ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_CUSTOM_AUTH",]
  prevent_user_existence_errors = "ENABLED"
  # allowed_oauth_flows           = ["code"]
  # allowed_oauth_scopes          = ["email", "openid", "profile"]
  callback_urls                 = ["http://localhost:8080"] # Replace with your actual callback URL
  logout_urls                   = ["http://localhost:8080"]
  # allowed_oauth_flows_user_pool_client = true
  supported_identity_providers  = ["COGNITO"]
}

resource "aws_wafv2_web_acl" "chat_acl" {
  name  = "chat-waf-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimit"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "chatACL"
  }
}

# HTTP API v2
resource "aws_apigatewayv2_api" "http_api" {
  name          = "fastapi-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["http://localhost:5173"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Authorization", "Content-Type"]
    expose_headers = ["Authorization"]
    max_age        = 3600
  }

}

# Cognito JWT Authorizer
resource "aws_apigatewayv2_authorizer" "cognito_jwt" {
  api_id          = aws_apigatewayv2_api.http_api.id
  authorizer_type = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name            = "cognito-jwt-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.chat_client.id]  # Replace with your user pool client id
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.chat_user_pool.id}"      # Replace with your user pool issuer URL
  }
}

# HTTP Integration with NLB Listener ARN (VPC_LINK)
resource "aws_apigatewayv2_integration" "http_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = aws_lb_listener.nlb_listener.arn   # NLB Listener ARN here
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.vpc_link.id
  payload_format_version = "1.0"
}

# Route using JWT Authorizer and Integration
resource "aws_apigatewayv2_route" "http_route" {
  api_id            = aws_apigatewayv2_api.http_api.id
  route_key         = "POST /chat"                          # Adjust path here if needed
  target            = "integrations/${aws_apigatewayv2_integration.http_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

# Default Stage with auto deployment
resource "aws_apigatewayv2_stage" "http_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}


# resource "aws_api_gateway_rest_api" "chat_api" {
#   name = "chat-api"
# }

# resource "aws_api_gateway_resource" "chat_resource" {
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   parent_id   = aws_api_gateway_rest_api.chat_api.root_resource_id
#   path_part   = "chat"
# }

# resource "aws_api_gateway_authorizer" "cognito_auth" {
#   name            = "chat-cognito-auth"
#   rest_api_id     = aws_api_gateway_rest_api.chat_api.id
#   type            = "COGNITO_USER_POOLS"
#   provider_arns   = [aws_cognito_user_pool.chat_user_pool.arn]
#   identity_source = "method.request.header.Authorization"
# }

# resource "aws_api_gateway_method" "chat_post" {
#   rest_api_id   = aws_api_gateway_rest_api.chat_api.id
#   resource_id   = aws_api_gateway_resource.chat_resource.id
#   http_method   = "POST"
#   authorization = "COGNITO_USER_POOLS"
#   authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
# }

# resource "aws_api_gateway_integration" "chat_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.chat_api.id
#   resource_id             = aws_api_gateway_resource.chat_resource.id
#   http_method             = aws_api_gateway_method.chat_post.http_method
#   integration_http_method = "POST"
#   type                    = "HTTP"
#   uri                     = "http://${aws_lb.nlb.dns_name}/chat"
# }

# resource "aws_api_gateway_deployment" "chat_deploy" {
#   depends_on  = [aws_api_gateway_integration.chat_integration]
#   rest_api_id = aws_api_gateway_rest_api.chat_api.id
#   # stage_name  = "prod"
# }

# resource "aws_api_gateway_stage" "chat_stage" {
#   rest_api_id  = aws_api_gateway_rest_api.chat_api.id
#   stage_name   = "prod"
#   deployment_id = aws_api_gateway_deployment.chat_deploy.id
# }

# resource "aws_wafv2_web_acl_association" "api_waf_attach" {
#   resource_arn = aws_api_gateway_stage.chat_stage.arn
#   web_acl_arn  = aws_wafv2_web_acl.chat_acl.arn
# }

# resource "aws_wafv2_web_acl_association" "api_waf_attach" {
#   resource_arn = "arn:aws:apigateway:${var.aws_region}::/restapis/${aws_apigatewayv2_api.http_api.id}/stages/${aws_apigatewayv2_stage.http_stage.name}"
#   web_acl_arn  = aws_wafv2_web_acl.chat_acl.arn
# }


# New Security Group for React EC2 allowing HTTP inbound from anywhere
resource "aws_security_group" "react_ec2_sg" {
  name        = "react-ec2-sg"
  description = "Allow HTTP traffic from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "react-ec2-sg"
  }
}

# EC2 instance for React App in public subnet with public IP
resource "aws_instance" "react_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.react_ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              yum update -y

              # Enable docker and install it
              amazon-linux-extras enable docker
              yum install -y docker git

              # Start Docker and add ec2-user to docker group
              service docker start
              usermod -aG docker ec2-user

              # Wait to ensure ec2-user is ready
              sleep 10

              # Clone the repo
              sudo -u ec2-user bash <<'EOC'
              cd /home/ec2-user

              if [ ! -d app ]; then
                git clone https://github.com/Siva-2707/DalFitBot.git app
              fi

              # Create frontend .env
              cat > /home/ec2-user/app/frontend/.env <<EOL
              VITE_AWS_REGION=${var.aws_region}
              VITE_USER_POOL_ID=${aws_cognito_user_pool.chat_user_pool.id}
              VITE_USER_POOL_CLIENT_ID=${aws_cognito_user_pool_client.chat_client.id}
              VITE_COGNITO_DOMAIN=${aws_cognito_user_pool_domain.my_domain.domain}
              VITE_CHAT_API_URL=${aws_apigatewayv2_api.http_api.api_endpoint}
              VITE_REDIRECT_SIGN_IN=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):80/
              VITE_REDIRECT_SIGN_OUT=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):80/
              EOL

              cd /home/ec2-user/app/frontend

              # Build Docker image
              docker build -t react-frontend .

              # Run container
              docker rm -f react-frontend || true
              docker run -d --name react-frontend -p 80:80 react-frontend
              EOC
              EOF

  tags = {
    Name = "react-ec2"
  }
}



output "user_pool_id" {
  value = aws_cognito_user_pool.chat_user_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.chat_client.id
}

output "region" {
  value = var.aws_region
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.my_domain.domain
}

output "react" {
  value = aws_instance.react_ec2.public_dns
}

output "http_api_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
  description = "The base URL of the deployed HTTP API"
}
