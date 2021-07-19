#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

data "aws_outposts_outpost" "target_outpost" {
  count = var.outposts_arn != "" ? 1 : 0
  arn   = var.outposts_arn
}

data "aws_ec2_coip_pool" "coip" {
  count = var.outposts_arn != "" ? 1 : 0
  filter {
    name   = "coip-pool.local-gateway-route-table-id"
    values = [data.aws_ec2_local_gateway_route_table.outposts_lgw_route_table[0].local_gateway_route_table_id]
  }
}

data "aws_ec2_local_gateway" "outposts_lgw" {
  filter {
    name   = "outpost-arn"
    values = [var.outposts_arn]
  }
}

data "aws_ec2_local_gateway_route_table" "outposts_lgw_route_table" {
  count       = var.outposts_arn != "" ? 1 : 0
  outpost_arn = var.outposts_arn
}

data "aws_region" "region" {
}

data "aws_caller_identity" "current" {
}



data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}