resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-bucket-web"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}