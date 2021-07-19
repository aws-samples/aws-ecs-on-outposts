#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

data "aws_vpc_endpoint_service" "s3" {
  count        = var.enable_ssm || var.enable_s3_endpoint ? 1 : 0
  service      = "s3"
  service_type = "Gateway"

}

resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_ssm || var.enable_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.vpc.id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-S3-ENDPOINT"
    },
  )
}

#this must be created outside of the module
#resource "aws_vpc_endpoint_route_table_association" "public_s3" {
#  count = var.enable_ssm ? 1 : 0
#  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
#  route_table_id  = aws_route_table.subnet_{subnet-type}_route_table[1].id
#}

