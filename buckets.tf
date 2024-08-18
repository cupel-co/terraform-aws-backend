resource "aws_s3_bucket" "primary" {
  provider = aws.primary

  bucket = var.primary_bucket_name

  lifecycle {
    prevent_destroy = true
  }
  
  tags = var.tags
}
resource "aws_s3_bucket_public_access_block" "primary" {
  provider = aws.primary

  bucket = aws_s3_bucket.primary.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
resource "aws_s3_bucket_acl" "primary" {
  provider = aws.primary

  bucket = aws_s3_bucket.primary.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary

  bucket = aws_s3_bucket.primary.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_replication_configuration" "primary" {
  provider = aws.primary
  
  depends_on = [aws_s3_bucket_versioning.primary]

  role   = aws_iam_role.primary_bucket_replication.arn
  bucket = aws_s3_bucket.primary.id

  rule {
    id = "all"
    
    delete_marker_replication {
      status = "Enabled"
    }
    
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.secondary.arn
      storage_class = "STANDARD"
    }
  }
}
data "aws_iam_policy_document" "primary_bucket_replication_role" {
  provider = aws.primary

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "primary_bucket_replication" {
  provider = aws.primary

  name               = "${aws_s3_bucket.primary.id}-replication"
  assume_role_policy = data.aws_iam_policy_document.primary_bucket_replication_role.json
  
  tags = var.tags
}
data "aws_iam_policy_document" "primary_bucket_replication" {
  provider = aws.primary

  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.primary.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.primary.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.secondary.arn}/*"]
  }
}
resource "aws_iam_policy" "primary_bucket_replication" {
  provider = aws.primary

  name   = "${aws_s3_bucket.primary.id}-replication"
  policy = data.aws_iam_policy_document.primary_bucket_replication.json

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "primary_bucket_replication" {
  provider = aws.primary

  role       = aws_iam_role.primary_bucket_replication.name
  policy_arn = aws_iam_policy.primary_bucket_replication.arn
}

resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary

  bucket = var.secondary_bucket_name
  
  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
resource "aws_s3_bucket_public_access_block" "secondary" {
  provider = aws.secondary

  bucket = aws_s3_bucket.secondary.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
resource "aws_s3_bucket_acl" "secondary" {
  provider = aws.secondary

  bucket = aws_s3_bucket.secondary.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "secondary" {
  provider = aws.secondary

  bucket = aws_s3_bucket.secondary.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_replication_configuration" "secondary" {
  provider = aws.secondary

  depends_on = [aws_s3_bucket_versioning.secondary]

  role   = aws_iam_role.secondary_bucket_replication.arn
  bucket = aws_s3_bucket.secondary.id

  rule {
    id = "all"

    delete_marker_replication {
      status = "Enabled"
    }

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.primary.arn
      storage_class = "STANDARD"
    }
  }
}
data "aws_iam_policy_document" "secondary_bucket_replication_role" {
  provider = aws.secondary

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "secondary_bucket_replication" {
  provider = aws.secondary

  name               = "${aws_s3_bucket.secondary.id}-replication"
  assume_role_policy = data.aws_iam_policy_document.secondary_bucket_replication_role.json

  tags = var.tags
}
data "aws_iam_policy_document" "secondary_bucket_replication" {
  provider = aws.secondary

  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.secondary.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.secondary.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.primary.arn}/*"]
  }
}
resource "aws_iam_policy" "secondary_bucket_replication" {
  provider = aws.secondary

  name   = "${aws_s3_bucket.secondary.id}-replication"
  policy = data.aws_iam_policy_document.secondary_bucket_replication.json

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "secondary_bucket_replication" {
  provider = aws.secondary

  role       = aws_iam_role.secondary_bucket_replication.name
  policy_arn = aws_iam_policy.secondary_bucket_replication.arn
}

resource "aws_iam_policy" "buckets_access" {
  provider = aws.primary

  description = "Terraform state buckets access"
  name = "${var.iam_prefix}StateBucketsAccess"
  policy = data.aws_iam_policy_document.buckets_access.json

  tags = var.tags
}
data "aws_iam_policy_document" "buckets_access" {
  provider = aws.primary

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning"
    ]
    resources = [
      aws_s3_bucket.primary.arn,
      aws_s3_bucket.secondary.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListObject",
      "s3:PutObject"
    ]
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = [
      "${aws_s3_bucket.primary.arn}/*",
      "${aws_s3_bucket.secondary.arn}/*"
    ]
  }
}
