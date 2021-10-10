output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.archive-raw-recordings.function_name
}
