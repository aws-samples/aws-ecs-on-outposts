#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#
locals {
  target_group_arns = [for k, v in aws_lb_target_group.ecs_alb_tg : aws_lb_target_group.ecs_alb_tg[k].arn]
  listener_port_coip = { for k, v in var.port_listeners :
    "port" => var.port_listeners[k]["port"]
  if var.outposts_arn != "" }
}