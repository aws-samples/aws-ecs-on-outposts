#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

################
# ECS LOG GROUPS
################

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  count             = var.import_aws_ecs_task_definition ? 0 : 1
  name              = "${var.vpc_name}-${var.tags["Project"]}-${var.log_group_name}"
  retention_in_days = var.log_retention_days
  tags = merge(
    var.tags,
    {
      "Purpose" = "CW log group for ECS"
      "Name"    = "${var.vpc_name}-${var.tags["Project"]}-${var.log_group_name}"
    },
  )
}