#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#ECS cluster
resource "aws_ecs_cluster" "ecs-cluster" {
  name               = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.asg.name]
}

#ECS service
resource "aws_ecs_service" "service" {
  depends_on = [aws_lb_target_group.ecs_alb_tg]

  name                               = "${var.tags["Project"]}-${var.ecs_service["ecs_service_name"]}"
  cluster                            = aws_ecs_cluster.ecs-cluster.id
  task_definition                    = var.import_aws_ecs_task_definition ? var.task_definition_arn : aws_ecs_task_definition.task_definition[0].arn
  desired_count                      = var.ecs_service["desired_count"]
  launch_type                        = var.ecs_service["launch_type"]
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  enable_ecs_managed_tags            = true

  tags = var.tags

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.port_listeners
    content {
      target_group_arn = aws_lb_target_group.ecs_alb_tg[load_balancer.key].arn
      container_name   = var.ecs_service["container_name"]
      container_port   = load_balancer.value["target_group"]["port"]
    }

  }

}

resource "aws_ecs_task_definition" "task_definition" {
  count      = var.import_aws_ecs_task_definition ? 0 : 1
  depends_on = [aws_cloudwatch_log_group.ecs_log_group]
  family     = var.ecs_service["task_definition"]["family"]
  container_definitions = jsonencode([
    {
      name      = var.ecs_service["container_name"]
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.region.name}.amazonaws.com/${var.ecr_name}"
      essential = true,
      cpu       = var.ecs_service["task_definition"]["cpu"]
      memory    = var.ecs_service["task_definition"]["memory"]
      portMappings = [
        {
          containerPort = var.ecs_service["task_definition"]["port"]
        }
      ]
      logConfiguration = {
        logDriver     = "awslogs",
        secretOptions = [],
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group[0].name,
          awslogs-region        = data.aws_region.region.name,
          awslogs-stream-prefix = var.ecs_service["container_name"]
        }
      }
      Environment = [
        { Name  = "REGION"
          Value = data.aws_region.region.name
        },
        {
          Name  = "STREAM_NAME"
          Value = var.kinesis_stream_name
        }
      ]
    }
  ])

  task_role_arn            = aws_iam_role.ecs_task_role[0].arn
  execution_role_arn       = aws_iam_role.ecs_execution_role[0].arn
  cpu                      = var.ecs_service["task_definition"]["cpu"]
  memory                   = var.ecs_service["task_definition"]["memory"]
  requires_compatibilities = [var.ecs_service["launch_type"]]
  network_mode             = "awsvpc"
  tags                     = var.tags
}