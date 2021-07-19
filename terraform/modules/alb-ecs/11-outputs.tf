#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

output "alb_id" {
  value = aws_lb.alb.id
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs-cluster.id
}

output "ecs_service_id" {
  value = aws_ecs_service.service.id
}

output "ecs_task_definition_id" {
  value = aws_ecs_task_definition.task_definition[0].arn
}

output "ecs_iam_execution_role" {
  value = aws_iam_role.ecs_execution_role[0].id
}

output "ecs_iam_task_role" {
  value = aws_iam_role.ecs_task_role[0].id
}

output "ecs_cw_log_group" {
  value = aws_cloudwatch_log_group.ecs_log_group[0].id
}
