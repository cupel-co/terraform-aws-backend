# OpenTofu Module AWS Backend

![Integrate](https://github.com/cupel-co/terraform-aws-backend/actions/workflows/integrate.yml/badge.svg?branch=main)

Provision AWS resources for OpenTofu backend. Resources provisioned: 
* DynamoDB global table
* IAM policy to access DynamoDB table  
* Primary bucket with replication to secondary
* Secondary bucket with replication to primary
* IAM policy to access primary and secondary buckets
* KMS Key for encryption of state on the client side with policy that is limited to the arns specified in `encryption_key_access_allowed_arns`

## Variables
| Variables                          | Description                                                                                                                                                                                                                                                                                            | Default     | Example |
|:-----------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------|:--------|
| dynamodb_name                      | The name of the table, this needs to be unique within a region.                                                                                                                                                                                                                                        |             |         |
| encryption_key_access_allowed_arns | The arns that are allowed to use the encryption key                                                                                                                                                                                                                                                    |             |         |
| iam_prefix                         | The prefix for IAM resources. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'. | `Terraform` |         |
| kms_alias                          | The alias for the encryption key.                                                                                                                                                                                                                                                                      | `terraform` |         |
| primary_bucket_name                | The name of the primary bucket. If omitted, OpenTofu will assign a random, unique name. Must be greater tha 9 and less than 64 characters in length.                                                                                                                                                   |             |         |
| secondary_bucket_name              | The name of the secondary bucket. If omitted, OpenTofu will assign a random, unique name. Must be greater tha 9 and less than 64 characters in length.                                                                                                                                                 |             |         |
| tags                               | Tags to add to resources.                                                                                                                                                                                                                                                                              | `{}`        |         |

## How to
Specify the module source and the provider information.

### Sample
```hcl
provider "aws" {
    alias = "primary"
    region = "ap-southeast-2"
    default_tags {
        tags = {
            Environment = "CICD"
            Owner       = "Platform"
            Project     = "OpenTofu State"
        }
    }
}

provider "aws" {
    alias = "secondary"
    region = "ap-southeast-4"
    default_tags {
        tags = {
            Environment = "CICD"
            Owner       = "Platform"
            Project     = "OpenTofu State"
        }
    }
}

module "backend" {
    source = "github.com/cupel-co/terraform-aws-backend?ref=v0.0.1"
    
    dynamodb_name = "OpenTofuLock"
    encryption_key_access_allowed_arns = [
        ""
    ]
    iam_prefix = "OpenTofu"
    kms_alias = "opentofu"
    primary_bucket_name = "cupel-OpenTofu-state-primary"
    secondary_bucket_name = "cupel-OpenTofu-state-secondary"
    tags = {
        CostCode = "123456"
    }
    providers = {
        aws.primary = aws.primary
        aws.secondary = aws.secondary
    }
}
```
