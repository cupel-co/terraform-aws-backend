variable "primary_bucket_name" {
  description = "The name of the primary bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length."
  type = string
  validation {
    condition = length(var.primary_bucket_name) >= 10 && length(var.primary_bucket_name) <= 63
    error_message = "The name should be between 10 and 63 characters long(inclusive)."
  }
}

variable "secondary_bucket_name" {
  description = "The name of the secondary bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length."
  type = string
  validation {
    condition = length(var.secondary_bucket_name) >= 10 && length(var.secondary_bucket_name) <= 63
    error_message = "The name should be between 10 and 63 characters long(inclusive)."
  }
}

variable "dynamodb_name" {
  description = "The name of the table, this needs to be unique within a region."
  type        = string
  validation {
    condition = length(var.dynamodb_name) >= 3 && length(var.dynamodb_name) <= 255
    error_message = "The name should be between 3 and 255 characters long(inclusive)."
  }
}

variable "iam_prefix" {
  description = "The prefix for IAM resources. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'."
  type        = string
  default     = "Terraform"
}
variable "encryption_key_access_allowed_arns" {
  description = "The arns that are allowed to use the encryption key"
  type        = list(string)
}

variable "tags" {
  description = "Tags to add to resources."
  type        = map(string)
  default     = {}
}
