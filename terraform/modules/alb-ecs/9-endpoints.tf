#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

# ################
# # EC2 SECURITY GROUPS
# ################

# #Question: is this compatible with outposts?

resource "aws_security_group" "ecs_endpoints_sec_group" {
  name        = "${var.vpc_name}-${var.tags["Project"]}-ecs-endpoint"
  description = "Allow ECS Sec group traffic"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-ecs-endpoint"
    },
  )

}


# ################
# # ENDPOINTS
# ################

# #FOR ECR API
data "aws_vpc_endpoint_service" "ecs" {
  service = "ecs"
}

resource "aws_vpc_endpoint" "ecs" {

  vpc_id            = data.aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ecs.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ecs_endpoints_sec_group.id]
  subnet_ids          = var.subnets
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-ecs-endpoint"
    },
  )
  lifecycle {
    ignore_changes = [service_name]
  }
}

data "aws_vpc_endpoint_service" "ecs-agent" {
  service = "ecs-agent"
}

resource "aws_vpc_endpoint" "ecs-agent" {

  vpc_id            = data.aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ecs-agent.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ecs_endpoints_sec_group.id]
  subnet_ids          = var.subnets
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-ecs-agent-endpoint"
    },
  )
  lifecycle {
    ignore_changes = [service_name]
  }
}

data "aws_vpc_endpoint_service" "ecs-telemetry" {
  service = "ecs-telemetry"
}

resource "aws_vpc_endpoint" "ecs-telemetry" {

  vpc_id            = data.aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ecs-telemetry.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ecs_endpoints_sec_group.id]
  subnet_ids          = var.subnets
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-ecs-telemetry-endpoint"
    },
  )
  lifecycle {
    ignore_changes = [service_name]
  }
}



# #FOR ECR API
data "aws_vpc_endpoint_service" "ecr_api" {
  service = "ecr.api"
}

resource "aws_vpc_endpoint" "ecr_api" {

  vpc_id            = data.aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ecr_api.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ecs_endpoints_sec_group.id]
  subnet_ids          = var.subnets
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-ecr-api-endpoint"
    },
  )
  lifecycle {
    ignore_changes = [service_name]
  }
}

# #FOR ECR DKR
data "aws_vpc_endpoint_service" "ecr_dkr" {
  service = "ecr.dkr"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = data.aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ecr_dkr.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ecs_endpoints_sec_group.id]
  subnet_ids          = var.subnets
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-ecr-dkr-endpoint"
    },
  )
  lifecycle {
    ignore_changes = [service_name]
  }
}


# #FOR SECRETS MANAGER - is it needed?
data "aws_vpc_endpoint_service" "secretsmanager" {
  service = "secretsmanager"
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = data.aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.secretsmanager.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ecs_endpoints_sec_group.id]
  subnet_ids          = var.subnets
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-secrets-manager-endpoint"
    },
  )
  lifecycle {
    ignore_changes = [service_name]
  }
}

# #FOR LOGS
data "aws_vpc_endpoint_service" "logs" {
  service = "logs"
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = data.aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.logs.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ecs_endpoints_sec_group.id]
  subnet_ids          = var.subnets
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tags["Project"]}-logs-endpoint"
    },
  )
  lifecycle {
    ignore_changes = [service_name]
  }
}

