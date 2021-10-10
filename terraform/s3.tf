# Logging bucket
resource "aws_kms_key" "logging-key" {
  description             = "This key is used to encrypt logging bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_public_access_block" "logging-public-access-block" {
  bucket = aws_s3_bucket.logging-bucket.id

  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_s3_bucket" "logging-bucket" {
  bucket = "${var.project_name}-logging-bucket"
  acl    = "log-delivery-write"

  logging {
    target_bucket = "${var.project_name}-logging-bucket"
    target_prefix = "${var.project_name}-logging-logs/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.logging-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }
}

# Raw Recordings bucket
resource "aws_kms_key" "raw-recordings-key" {
  description             = "This key is used to encrypt raw-recordings bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_public_access_block" "raw-recordings-public-access-block" {
  bucket = aws_s3_bucket.raw-recordings-bucket.id

  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_s3_bucket" "raw-recordings-bucket" {
  bucket = "${var.project_name}-raw-recordings"
  acl    = "private"

  logging {
    target_bucket = aws_s3_bucket.logging-bucket.id
    target_prefix = "${var.project_name}-raw-recordings-bucket-logs/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.raw-recordings-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }
}

# Lambdas bucket
resource "aws_kms_key" "lambdas-key" {
  description             = "This key is used to encrypt raw-recordings bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_public_access_block" "lambdas-public-access-block" {
  bucket = aws_s3_bucket.lambdas-bucket.id

  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_s3_bucket" "lambdas-bucket" {
  bucket = "${var.project_name}-lambdas"
  acl           = "private"
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.logging-bucket.id
    target_prefix = "${var.project_name}-lambdas-bucket-logs/"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.lambdas-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }
}
