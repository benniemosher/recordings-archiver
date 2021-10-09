# Logging bucket
resource "aws_kms_key" "logging_key" {
  description             = "This key is used to encrypt logging bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "logging-bucket"
  acl    = "log-delivery-write"

  logging {
    target_bucket = "logging-bucket"
    target_prefix = "loggings_logs/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.raw_recordings_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Raw Recordings bucket
resource "aws_kms_key" "raw_recordings_key" {
  description             = "This key is used to encrypt raw_recordings bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "raw_recordings_bucket" {
  bucket = "raw_recordings"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.logging_bucket.id
    target_prefix = "raw_recordings_s3_bucket_logs/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.raw_recordings_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
