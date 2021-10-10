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
