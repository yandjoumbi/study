provider "aws" {
  region = "us-west-2"  # Update with your desired region
}

# Define the AWS Lambda function
resource "aws_lambda_function" "delete_unused_elastic_ips" {
  filename         = "lambda_function.zip"  # Path to your Lambda function code
  function_name    = "delete_unused_elastic_ips"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
}

# Define the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach a policy to the IAM role that allows the Lambda function to interact with EC2
resource "aws_iam_role_policy_attachment" "lambda_ec2_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.lambda_role.name
}

# Define the CloudWatch Events rule to trigger the Lambda function every 5 minutes
resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name                = "delete_unused_elastic_ips_trigger"
  schedule_expression = "cron(*/5 * * * ? *)"
}

# Define the target for the CloudWatch Events rule (the Lambda function)
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  target_id = "delete_unused_elastic_ips_target"
  arn       = aws_lambda_function.delete_unused_elastic_ips.arn
}

# Grant permissions for CloudWatch Events to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_unused_elastic_ips.function_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.lambda_trigger.arn
}