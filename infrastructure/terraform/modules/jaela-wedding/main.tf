locals {
    common-tags  = {
      "lifecycle"   = "persistent",
      "environment" = var.environment,
      "service"     = var.service-name,
      "customer"    = "rocroofing"
    }
}

#########################################################
################### Target EKS Cluster ##################
#########################################################
data "aws_eks_cluster" "cluster_data" {
  name = var.cluster-name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = "${data.aws_eks_cluster.cluster_data.name}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_iam_openid_connect_provider" "cluster_oidc" {
  url = data.aws_eks_cluster.cluster_data.identity[0].oidc[0].issuer
}

data "aws_caller_identity" "user" {
}

data "aws_ses_domain_identity" "ses_domain" {
  domain = "rocroofingfl.com"
}

############################################################
################### Application S3 Bucket ##################
############################################################
resource "aws_kms_key" "jaela_wedding_bucket" {
  description = "KMS key for encrypting the S3 bucket for ${var.service-name}-${var.environment}."
  policy      = null
  tags        = merge(
    tomap({
        "Name": "${var.service-name}-${var.environment}"
    }),
    local.common-tags
  )
}

resource "aws_kms_alias" "jaela_wedding_bucket" {
  name          = "alias/${var.service-name}-${var.environment}-s3-kms"
  target_key_id = aws_kms_key.jaela_wedding_bucket.key_id
}

resource "aws_s3_bucket" "jaela_wedding_bucket" {
  bucket = "${var.service-name}-${var.environment}"
  acl = "private"
  policy = null

  versioning {
    enabled = true
  }

  tags = merge(
    tomap({
        "Name": "${var.service-name}-${var.environment}"
    }),
    local.common-tags
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.jaela_wedding_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.jaela_wedding_bucket.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "encrypted_bucket_access" {
  bucket = aws_s3_bucket.jaela_wedding_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

############################################################
################### Application SQS Queue ##################
############################################################
resource "aws_sqs_queue" "jaela_wedding_worker_queue" {
  name = "${var.service-name}-${var.environment}"
}

############################################################
################# Application IRSA Policy ##################
############################################################
resource "aws_iam_policy" "jaela_wedding_prod_irsa" {
  name = "ironwolf-us-west-2-k8s-jaela-wedding-prod-irsa-policy"
  path = "/"
  description = "Allows Jaela Wedding pods to communicate with S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": ["${aws_s3_bucket.jaela_wedding_bucket.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${aws_s3_bucket.jaela_wedding_bucket.arn}/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:DescribeKey",
        "kms:GenerateDataKey",
        "kms:GenerateDataKeys",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": ["${data.aws_ses_domain_identity.ses_domain.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ListQueues"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:*"
      ],
      "Resource": ["${aws_sqs_queue.jaela_wedding_worker_queue.arn}"]
    }
  ]
}
EOF
}

module "rocroofing_prod_service_account" {
  source                  = "../../modules/irsa"
  common_tags             = local.common-tags
  name                    = "rocroofing-prod-irsa"
  eks_cluster_name        = var.cluster-name
  oidc_provider_url       = data.aws_eks_cluster.cluster_data.identity[0].oidc[0].issuer
  oidc_provider_arn       = data.aws_iam_openid_connect_provider.cluster_oidc.arn
  create_service_account  = true
  namespaces              = ["ocdhomes"]
  access_policy_arn       = aws_iam_policy.jaela_wedding_prod_irsa.arn
}
