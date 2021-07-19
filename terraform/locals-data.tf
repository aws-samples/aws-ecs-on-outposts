#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

locals {
  common_tags = {
    Environment      = var.Environment
    Project          = var.Project
    Owner            = var.Owner
    managedBy        = "terraform"
    Terraformbackend = "terraform-backend-s3"
  }

  outposts_alb_logging_region_account_id_bucket_policy = {
    "us-east-1" : "127311923021",
    "us-east-2" : "033677994240",
    "us-west-1" : "027434742980",
    "us-west-2" : "797873946194",
    "eu-west-1" : "156460612806",
    "eu-west-2" : "652711504416"
  }
}


data "aws_region" "region" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

data "aws_outposts_outpost" "target_outpost" {
  arn = var.outposts_arn
}