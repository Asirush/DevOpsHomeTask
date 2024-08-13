resource "aws_lb" "nlb" {
  name               = "devops-hometask-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.subnet.id]

  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "devops-hometask-nlb-tg"
  port     = 8080
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }

  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "manage_nlb" {
  function_name = "manage_nlb_targets"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  timeout       = 60

  filename = "lambda_function.zip"

  environment {
    variables = {
      VPC_ID       = aws_vpc.main.id
      TARGET_GROUP = aws_lb_target_group.main.id
    }
  }

  tags = {
    Application = "DevOpsHomeTask"
  }
}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "run_every_5_minutes"
  description         = "Lambda runs every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.manage_nlb.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.manage_nlb.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
