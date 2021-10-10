data "archive_file" "archive-raw-recordings" {
  type = "zip"

  source_dir  = "${path.module}/../archive-raw-recordings"
  output_path = "${path.module}/../archive-raw-recordings.zip"
}

resource "aws_s3_bucket_object" "archive-raw-recordings" {
  bucket = aws_s3_bucket.lambdas-bucket.id

  key    = "archive-raw-recordings.zip"
  source = data.archive_file.archive-raw-recordings.output_path

  etag = filemd5(data.archive_file.archive-raw-recordings.output_path)
}

resource "aws_lambda_function" "archive-raw-recordings" {
  function_name = "ArchiveRawRecordings"

  s3_bucket = aws_s3_bucket.lambdas-bucket.id
  s3_key    = aws_s3_bucket_object.archive-raw-recordings.key

  runtime = "nodejs12.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.archive-raw-recordings.output_base64sha256

  role = aws_iam_role.archive-raw-recordings.arn
}

resource "aws_cloudwatch_log_group" "archive-raw-recordings" {
  name = "/aws/lambda/${aws_lambda_function.archive-raw-recordings.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "archive-raw-recordings" {
  name = "archive-raw-recordings-lambda"

  assume_role_policy = data.aws_iam_policy_document.archive-raw-recordings-assume-role.json
}

data "aws_iam_policy_document" "archive-raw-recordings-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "archive-raw-recordings-policy" {
  role       = aws_iam_role.archive-raw-recordings.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_integration" "archive-raw-recordings" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.archive-raw-recordings.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "archive-raw-recordings" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.archive-raw-recordings.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.archive-raw-recordings.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
