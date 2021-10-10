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
