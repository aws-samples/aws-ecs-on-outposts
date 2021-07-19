#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

resource "aws_ecs_capacity_provider" "asg" {
  /* The immutable dependency of an ECS capacity provider on a specific ASG is a major pain point.
   * Since this relationship is enforced as 1-to-1, the name of the capacity provider should reflect
   * the name of the ASG.
   * See  https://github.com/aws/containers-roadmap/issues/632
   * Also https://github.com/aws/containers-roadmap/issues/633
   */

  name = aws_autoscaling_group.ecs_nodes.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_nodes.arn
    managed_termination_protection = var.capacity_provider_managed_termination_protection

    managed_scaling {
      maximum_scaling_step_size = var.maximum_scaling_step_size
      minimum_scaling_step_size = var.minimum_scaling_step_size
      status                    = "ENABLED"
      target_capacity           = var.capacity_provider_target_capacity
    }
  }

  lifecycle {
    ignore_changes = [auto_scaling_group_provider]
  }
}


resource "aws_autoscaling_group" "ecs_nodes" {
  name_prefix         = var.ecs_asg_name_prefix
  max_size            = var.ecs_asg_max_size
  min_size            = var.ecs_asg_min_size
  desired_capacity    = var.ecs_asg_desired_capacity
  vpc_zone_identifier = var.subnets
  health_check_type   = var.ecs_asg_health_check_type

  capacity_rebalance        = var.ecs_asg_capacity_rebalance
  default_cooldown          = var.ecs_asg_default_cooldown
  health_check_grace_period = var.ecs_asg_health_check_grace_period
  termination_policies      = var.ecs_asg_termination_policies
  suspended_processes       = var.ecs_asg_suspended_processes
  enabled_metrics           = var.ecs_asg_enabled_metrics
  protect_from_scale_in     = var.ecs_asg_protect_from_scale_in

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = var.import_aws_launch_template ? var.launch_template_id : aws_launch_template.node[0].id
        version            = "$Latest"
      }
      dynamic "override" {
        for_each = var.ecs_asg_override_config
        content {
          instance_type     = lookup(override.value, "instance_type", null)
          weighted_capacity = lookup(override.value, "weighted_capacity", null)
        }
      }
    }
  }

  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.ecs_asg_name_prefix
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.tags["Project"]
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = var.tags["Owner"]
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}


data "template_file" "ecs_ec2_user_data" {
  count    = var.import_aws_launch_template ? 0 : 1
  template = file("${path.module}/user-data/user-data.sh")

  vars = {
    clustername = var.ecs_cluster_name
    Region      = data.aws_region.region.name
  }
}

resource "aws_launch_template" "node" {
  count                  = var.import_aws_launch_template ? 0 : 1
  name_prefix            = var.launch_template_name_prefix
  image_id               = var.ecs_ami_id
  instance_type          = var.ecs_instance_type
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  user_data              = base64encode(data.template_file.ecs_ec2_user_data[0].rendered)
  tags                   = var.tags
  update_default_version = true


  iam_instance_profile {
    name = var.ec2_iam_instance_profile
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = flatten(list(lookup(block_device_mappings.value, "ebs", [])))
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", null)
          iops                  = lookup(ebs.value, "iops", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
        }
      }
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

}