data "aws_region" "primary" {
  provider = aws.primary
}
data "aws_region" "secondary" {
  provider = aws.secondary
}

data "aws_caller_identity" "primary" {
  provider = aws.primary
}
data "aws_caller_identity" "secondary" {
  provider = aws.secondary
}
