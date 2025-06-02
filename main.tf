#Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

#Provider Configuration
provider "aws" {
  region     = var.aws_region
}

#Network Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true         # Enable DNS support for the VPC
  tags = { Name = "fastapi-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet" }
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

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "private-subnet" }
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
    email_subject        = "Verify your email for DalFitBot"
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
  callback_urls                 = ["http://localhost:8080"]
  logout_urls                   = ["http://localhost:8080"]
  supported_identity_providers  = ["COGNITO"]
}
# HTTP API v2
resource "aws_apigatewayv2_api" "http_api" {
  name          = "fastapi-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]  # Adjust to your React app's URL
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
  integration_uri        = "http://${aws_lb.nlb.dns_name}:80/{proxy}"
  integration_method     = "ANY"

}

# Route using JWT Authorizer and Integration
resource "aws_apigatewayv2_route" "http_route" {
  api_id            = aws_apigatewayv2_api.http_api.id
  route_key           = "ANY /{proxy}"
  # route_key         = "POST /chat"
  target            = "integrations/${aws_apigatewayv2_integration.http_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_jwt.id
}

# Default Stage with auto deployment
resource "aws_apigatewayv2_stage" "http_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.dalfitbot_log_group.arn
    format = jsonencode({
      requestId : "$context.requestId",
      integrationStatus : "$context.integration.status",
      integrationError : "$context.integrationErrorMessage",
      authorizerError : "$context.authorizer.error"
    })
  }
}

resource "aws_security_group" "vpc_link_sg" {
  name        = "vpc-link-sg"
  description = "Allow HTTP from NLB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_apigatewayv2_vpc_link" "vpc_link" {
#   name               = "fastapi-vpc-link"
#   subnet_ids         = [aws_subnet.public.id]
#   security_group_ids = [aws_security_group.vpc_link_sg.id]
# }

# resource "aws_wafv2_web_acl" "chat_acl" {
#   name  = "chat-waf-acl"
#   scope = "REGIONAL"

#   default_action {
#     allow {}
#   }

#   rule {
#     name     = "RateLimitRule"
#     priority = 1

#     action {
#       block {}
#     }

#     statement {
#       rate_based_statement {
#         limit              = 1000
#         aggregate_key_type = "IP"
#       }
#     }

#     visibility_config {
#       sampled_requests_enabled   = true
#       cloudwatch_metrics_enabled = true
#       metric_name                = "rateLimit"
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     sampled_requests_enabled   = true
#     metric_name                = "chatACL"
#   }
# }

resource "aws_lb" "nlb" {
  name               = "fastapi-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public.id]
  # subnets            = [aws_subnet.private.id]
}

resource "aws_lb_target_group" "tg" {
  name        = "fastapi-tg"
  # port        = 80
  port        = 8080
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    protocol            = "TCP"
    port                = "8080"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
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

resource "aws_key_pair" "dalfitbot_key" {
  key_name   = "dalfitbot-key"
  public_key = file("~/.ssh/dalfitbot-key.pub") # or any valid public key path
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

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
  key_name                    = aws_key_pair.dalfitbot_key.key_name   

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
              VITE_CHAT_API_URL=http://${aws_lb.nlb.dns_name}
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
  ingress {
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
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
}

resource "aws_instance" "fastapi_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "c7a.large"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.dalfitbot_key.key_name
  monitoring                  = true

  root_block_device {
    volume_size = 32
    volume_type = "gp2"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update packages
              yum update -y

              # Enable Docker and install necessary packages
              amazon-linux-extras enable docker
              yum install -y docker git

              # Start Docker and enable on boot
              systemctl start docker
              systemctl enable docker

              # Add ec2-user to the docker group
              usermod -aG docker ec2-user

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Run app setup as ec2-user
              runuser -l ec2-user -c '
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

  depends_on = [
    aws_internet_gateway.gw,
    aws_nat_gateway.this,
    aws_route_table.private,
    aws_subnet.private
  ]
}

# Monitoring configurations

resource "aws_cloudwatch_log_group" "dalfitbot_log_group" {
  name              = "/dalfitbot/"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "HighCPUUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggered when EC2 CPU exceeds 80%"
  actions_enabled     = false  # Set true if using SNS to notify
  dimensions = {
    InstanceId = aws_instance.fastapi_ec2.id
  }
}

resource "aws_cloudwatch_dashboard" "main_dashboard" {
  dashboard_name = "DalFitBotDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.fastapi_ec2.id ]
          ],
          view = "timeSeries",
          region = var.aws_region,
          title = "EC2 CPU Usage"
        }
      }
    ]
  })
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
