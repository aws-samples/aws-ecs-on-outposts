#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

################
# ALB
################

resource "aws_security_group" "alb_sg" {
  name        = "${var.vpc_name}-${var.tags["Project"]}-${var.alb_name}-sec-group"
  description = "Security group for ECS ALB"
  vpc_id      = data.aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-${var.alb_name}-sec-group"
    },
  )

}

#inbound traffic - custom cidr
resource "aws_security_group_rule" "alb_listener_in" {
  for_each          = var.port_listeners
  type              = "ingress"
  from_port         = each.value["port"]
  to_port           = each.value["port"]
  protocol          = "tcp"
  cidr_blocks       = each.value["inbound_cidr_range"]
  security_group_id = aws_security_group.alb_sg.id
}

#inbound traffic - from customer on prem
resource "aws_security_group_rule" "alb_listener_in_coip" {
  for_each          = local.listener_port_coip
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = data.aws_ec2_coip_pool.coip[0].pool_cidrs
  security_group_id = aws_security_group.alb_sg.id
}


# outbound traffic - ALB health check & traffic to ECS
# if health check port & protocol = traffic port & protocol
resource "aws_security_group_rule" "alb_healthcheck_egress" {
  for_each                 = var.port_listeners
  type                     = "egress"
  from_port                = each.value["target_group"]["port"]
  to_port                  = each.value["target_group"]["port"]
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_sg.id
  description              = "allow egress traffic for health check"
  security_group_id        = aws_security_group.alb_sg.id
}

################
# ECS
################

resource "aws_security_group" "ecs_sg" {
  name        = "${var.vpc_name}-${var.tags["Project"]}-ecs-sec-group"
  description = "Security group for ECS"
  vpc_id      = data.aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-ecs-sec-group"
    },
  )
}

#health check from ALB & traffic from ALB
resource "aws_security_group_rule" "ecs_alb_in" {
  for_each                 = var.port_listeners
  type                     = "ingress"
  from_port                = each.value["target_group"]["port"]
  to_port                  = each.value["target_group"]["port"]
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  description              = "allow ingress traffic from alb health check"
  security_group_id        = aws_security_group.ecs_sg.id
}

#not required - ALB ip address, source ip address is in X-FW-For http header
# resource "aws_security_group_rule" "ecs_traffic_in" {
#   for_each          = var.port_listeners
#   type              = "ingress"
#   from_port         = each.value["target_group"]["port"]
#   to_port           = each.value["target_group"]["port"]
#   protocol          = "tcp"
#   cidr_blocks       = each.value["inbound_cidr_range"]
#   description       = "allow ingress traffic from customer"
#   security_group_id = aws_security_group.ecs_sg.id
# }

#update depending on requirements
resource "aws_security_group_rule" "ecs_traffic_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "allow ALL egress traffic"
  security_group_id = aws_security_group.ecs_sg.id
}