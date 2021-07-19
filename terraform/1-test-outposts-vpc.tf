#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#
module "test-vpc" {
  source                  = "./modules/vpc"
  tags                    = local.common_tags
  vpc_name                = var.vpc_name
  vpc_suffix              = var.vpc_suffix
  vpc_main_cidr           = var.vpc_main_cidr
  enable_ipv6             = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_internet_gateway = true
  enable_nat_gateway      = true
  enable_ssm              = true
  create_iam_role_ssm     = true

  number_AZ    = var.number_AZ
  endpoints_ha = true

  private_subnets_cidr_list  = var.private_subnets_cidr_list
  outposts_subnets_cidr_list = var.outposts_subnets_cidr_list
  public_subnets_cidr_list   = var.public_subnets_cidr_list

  outposts_subnets_internet_access_nat_gw = true
  outposts_arn                            = var.outposts_arn
  outposts_route_to_LGW_destination       = var.outposts_route_to_LGW_destination
  outposts_local_gateway_id               = var.outposts_local_gateway_id

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

}

#route table to S3 VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "route_outposts_subnet_s3" {
  count           = length(module.test-vpc.subnet_outposts_route_table_ids)
  vpc_endpoint_id = module.test-vpc.s3_vpc_endpoint
  route_table_id  = module.test-vpc.subnet_outposts_route_table_ids[count.index]
}