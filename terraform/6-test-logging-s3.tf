#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

# #KMS not available - either SSE-S3 or SSE-C
resource "aws_s3_bucket" "s3_bucket_outposts_logging" {
  bucket = var.s3_bucket_outposts_logging_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      "Purpose" = "S3 bucket for outposts logging"
    },
  )
}

resource "aws_s3_bucket_policy" "s3_policy_outposts_logging" {
  bucket = aws_s3_bucket.s3_bucket_outposts_logging.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sspolicy",
  "Statement": [
    {
            "Sid": "EnforceHttpsAlways",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_outposts_logging_name}",
                "arn:aws:s3:::${var.s3_bucket_outposts_logging_name}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        },
        {
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${local.outposts_alb_logging_region_account_id_bucket_policy[data.aws_region.region.name]}:root"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${var.s3_bucket_outposts_logging_name}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        },
        {
        "Effect": "Allow",
        "Principal": {
            "Service": ["delivery.logs.amazonaws.com", "logdelivery.elb.amazonaws.com"]
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${var.s3_bucket_outposts_logging_name}/${var.alb_access_logs_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        "Condition": {
            "StringEquals": {
            "s3:x-amz-acl": "bucket-owner-full-control"
            }
        }
        },
        {
        "Effect": "Allow",
        "Principal": {
            "Service":  ["delivery.logs.amazonaws.com", "logdelivery.elb.amazonaws.com"]
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "arn:aws:s3:::${var.s3_bucket_outposts_logging_name}"
        }
  ]
}
POLICY
}
