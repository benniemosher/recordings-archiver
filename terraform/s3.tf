resource "aws_s3_bucket" "raw_recordings_bucket" {
  bucket = "raw_recordings"
  acl = "private"
}
