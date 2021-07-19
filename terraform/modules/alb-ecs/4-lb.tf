#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#


################
# APPLICATION LOAD BALANCER
################

resource "aws_lb" "alb" {
  name                       = var.alb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.subnets
  enable_deletion_protection = var.alb_enable_deletion_protection
  customer_owned_ipv4_pool   = var.outposts_arn != "" ? data.aws_ec2_coip_pool.coip[0].id : null
  ip_address_type            = var.alb_ip_address_type

  access_logs {
    bucket  = var.logging_bucket_name
    prefix  = var.enable_alb_access_logging ? var.alb_access_logs_prefix : null
    enabled = var.enable_alb_access_logging
  }

  tags = var.tags

}

#---------------ROUTE 53 RECORD & ACM certificate ----------------------------------------
data "aws_route53_zone" "hostedzone" {
  count   = var.custom_zone ? 1 : 0
  zone_id = var.zone_id
}

#ALB - ALIAS NAME
resource "aws_route53_record" "HostRecordALB" {
  count   = var.custom_zone ? 1 : 0
  zone_id = data.aws_route53_zone.hostedzone[0].zone_id
  name    = "${var.alb_name}.${data.aws_route53_zone.hostedzone[0].name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

#ACM certificate
resource "aws_acm_certificate" "alb-cert" {
  count             = var.custom_zone ? 1 : 0
  depends_on        = [aws_lb.alb, aws_route53_record.HostRecordALB[0]]
  domain_name       = "${var.alb_name}.${data.aws_route53_zone.hostedzone[0].name}"
  validation_method = "DNS"

  tags = merge(
    var.tags,
    {
      "Name" = "${var.alb_name}-ALB-certificate"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "alb_cert_validation" {
  depends_on = [aws_lb.alb, aws_acm_certificate.alb-cert[0]]
  for_each = var.custom_zone ? {
    for dvo in aws_acm_certificate.alb-cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hostedzone[0].zone_id

}

resource "aws_acm_certificate_validation" "alb-cert" {
  count           = var.custom_zone ? 1 : 0
  depends_on      = [aws_lb.alb]
  certificate_arn = aws_acm_certificate.alb-cert[0].arn
  #validation_record_fqdns = [aws_route53_record.alb_cert_validation.fqdn]
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation[0] : record.fqdn]
}


################
# TARGET GROUPS
################

#To solve terraform issue https://github.com/hashicorp/terraform-provider-aws/issues/636
resource "random_string" "target_group" {
  length  = 4
  special = false
}

#health check on traffic port - this can be updated
resource "aws_lb_target_group" "ecs_alb_tg" {
  for_each             = var.port_listeners
  name                 = "${var.alb_name}-${each.value["port"]}-${random_string.target_group.result}"
  vpc_id               = data.aws_vpc.vpc.id
  port                 = each.value["target_group"]["port"]
  protocol             = each.value["target_group"]["protocol"]
  target_type          = "ip"
  deregistration_delay = var.target_group_deregistration_delay

  health_check {
    interval            = var.target_group_health_check_interval
    protocol            = each.value["target_group"]["protocol"]
    port                = each.value["target_group"]["port"]
    path                = each.value["target_group"]["health_check_path"]
    timeout             = var.target_group_health_check_timeout
    matcher             = var.target_group_health_check_matcher
    healthy_threshold   = var.target_group_healthy_threshold
    unhealthy_threshold = var.target_group_unhealthy_threshold
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

}


################
# LISTENER
################

resource "aws_lb_listener" "listener" {
  depends_on        = [aws_lb_target_group.ecs_alb_tg]
  for_each          = var.port_listeners
  load_balancer_arn = aws_lb.alb.arn
  port              = each.value["port"]
  protocol          = each.value["protocol"]

  ssl_policy      = each.value["protocol"] == "HTTPS" && var.custom_zone ? "ELBSecurityPolicy-FS-2018-06" : null
  certificate_arn = each.value["protocol"] == "HTTPS" && var.custom_zone ? aws_acm_certificate_validation.alb-cert[0].certificate_arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_tg[each.key].arn
  }
}


################
# LISTENER RULE - TO CUSTOMIZE
################

#it will be useful if different type of ECS tasks
# resource "aws_lb_listener_rule" "listenerRule" {
#   for_each = var.port_listeners
#   listener_arn = aws_lb_listener.listener[each.key].arn
#   priority     = 

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ecs_alb_tg.arn
#   }

#   condition {
#     host_header {
#       values = []
#     }
#   }
# }



