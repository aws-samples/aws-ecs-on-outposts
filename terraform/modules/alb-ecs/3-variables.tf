#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#-----------------------PROJECT RELATED
variable "tags" {
  type        = map(string)
  description = "[Required] Tags to apply to the resources"
}

variable "vpc_name" {
  type        = string
  description = "[Required] name of the VPC where the resources will be deployed"
}

#---------------------APPLICATION LOAD BALANCER---------------------------------


variable "alb_name" {
  description = "[Required] Name of the application load balancer"
  type        = string
}


variable "subnets" {
  description = "[Required] A list of subnet IDs to associate with the load balancer."
  type        = list(string)
}

variable "custom_zone" {
  description = "[Optional] True for using a custom domain name for the ALB. A certificate will be created too. Protocol should be HTTPS"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "[Optional] Zone Id of your custom domain if custom_zone is set to true"
  type        = string
  default     = ""
}

variable "enable_alb_access_logging" {
  description = "[Optional] true to enable access logging on ALB"
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "[Optional] Name of the s3 bucket to sends access logs from alb"
  type        = string
  default     = ""
}

variable "alb_access_logs_prefix" {
  description = "[Optional] prefix for the access logs sent to s3 bucket from alb"
  type        = string
  default     = "alb/outposts"
}


# variable "vpc_id" {
#   description = "[Required] VPC id where the load balancer and other resources will be deployed."
#   type        = string
# }

# port_listeners = {
#   "port-1" = {
#     "port"      = 80,
#     "protocol"  = "HTTP",
#     "inbound_cidr_range" = []
#     "target_group" = {
#       "port" = 8080,
#       "protocol" = "HTTP",
#       "health_check_path" = "/"
#     }
#   },
# }

variable "port_listeners" {
  description = "[optional] A list of maps describing the HTTP/S listeners for this ALB. Required key/values: port, protocol."
  type        = any
  default = {
    "port-1" = {
      "port"               = 80,
      "protocol"           = "HTTP",
      "inbound_cidr_range" = []
      "target_group" = {
        "port"              = 8080,
        "protocol"          = "HTTP",
        "health_check_path" = "/"
      }
    },
  }
}

variable "alb_enable_deletion_protection" {
  description = "[optional] True to enable ALB deletion protection"
  type        = bool
  default     = false
}

variable "alb_ip_address_type" {
  description = "[optional] The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"
  type        = string
  default     = "ipv4"
}

variable "target_group_deregistration_delay" {
  description = "[optional] The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds."
  type        = number
  default     = 300
}

variable "target_group_health_check_interval" {
  description = "[optional] The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds."
  type        = number
  default     = 30
}

# variable "target_group_health_check_path" {
#   description = "[optional] The destination for the health check request."
#   type        = string
#   default     = "/"
# }

variable "target_group_health_check_timeout" {
  description = "[optional] The amount of time, in seconds, during which no response means a failed health check. The range is 2 to 120 seconds"
  type        = number
  default     = 10
}

variable "target_group_health_check_matcher" {
  description = "[optional] The response codes to use when checking for a healthy responses from a target."
  type        = string
  default     = "200-399"
}

variable "target_group_healthy_threshold" {
  description = "[optional] The number of consecutive health checks successes required before considering an unhealthy target healthy."
  type        = number
  default     = 3
}

variable "target_group_unhealthy_threshold" {
  description = "[optional] The number of consecutive health check failures required before considering the target unhealthy."
  type        = number
  default     = 3
}

#---------------------OUTPOSTS---------------------------------
variable "outposts_arn" {
  description = "[Optional] Outposts ARN Id if applicable"
  type        = string
  default     = ""
}

#-------------------------ECS------------------------------------------------
variable "ecs_cluster_name" {
  description = "[Required] Name for ECS cluster."
  type        = string
}

variable "ecs_service" {
  description = "[Required] Name for ECS cluster."
  type = object({
    ecs_service_name = string
    desired_count    = number
    launch_type      = string
    container_name   = string
    task_definition = object({
      family = string
      cpu    = number
      memory = number
      port   = number
    })
  })

  default = {
    "ecs_service_name" = "ecs-producer",
    "desired_count"    = 1,
    "launch_type"      = "EC2",
    "container_name"   = "producer",
    "task_definition" = {
      "family" = "producer",
      "cpu"    = 512,
      "memory" = 1024,
      "port"   = 8080
    }
  }
}


variable "import_aws_ecs_task_definition" {
  description = "[Optional] true if you want to import an existing task definition"
  type        = bool
  default     = false
}

variable "task_definition_arn" {
  description = "[Optional] Define if you are importing an existing task definition"
  type        = string
  default     = ""
}

variable "log_group_name" {
  description = "[Required] name for AWS CW Log for ECS"
  type        = string
}

variable "log_retention_days" {
  description = "[Optional] retention period for AWS CW Log"
  type        = number
  default     = 365
}

variable "ecr_name" {
  description = "[Optional] name for ECR"
  type        = string
  default     = "kinesis/producer"
}

#----------------CAPACITY PROVIDER-------------------

variable "ecs_ami_id" {
  description = "[Optional] AMI ID for EC2"
  type        = string
  default     = "ami-017a715104f93ea81"
}

variable "ecs_instance_type" {
  description = "[Optional] instance type for EC2"
  type        = string
  default     = "m5.2xlarge"
}


variable "ec2_iam_instance_profile" {
  description = "[Required] iam instance profile for EC2"
  type        = string
}

#-------------- ecs auto scaling ---
variable "maximum_scaling_step_size" {
  description = "[Optional] maximum step adjustment size for ECS Auto Scaling"
  type        = number
  default     = 1
}

variable "minimum_scaling_step_size" {
  description = "[Optional] minimum step adjustment size for ECS Auto Scaling"
  type        = number
  default     = 1
}


variable "capacity_provider_managed_termination_protection" {
  description = "[Optional]  Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens. Valid values are ENABLED and DISABLED."
  type        = string
  default     = "DISABLED"
}


variable "capacity_provider_target_capacity" {
  description = "[Optional] The target utilization for the capacity provider. A number between 1 and 100."
  type        = number
  default     = 80
}

variable "ecs_asg_name_prefix" {
  description = "[Optional]  Creates a unique name beginning with the specified prefix."
  type        = string
  default     = "OUTPOST_ECS"
}

variable "ecs_asg_max_size" {
  description = "[Optional] The maximum size of the Auto Scaling Group."
  type        = number
  default     = 3
}


variable "ecs_asg_min_size" {
  description = "[Optional] The minimum size of the Auto Scaling Group."
  type        = number
  default     = 0
}

variable "ecs_asg_desired_capacity" {
  description = "[Optional] The number of Amazon EC2 instances that should be running in the group."
  type        = number
  default     = 1
}



variable "ecs_asg_health_check_type" {
  description = "[Optional] EC2 or ELB. Controls how health checking is done."
  type        = string
  default     = "ELB"
}


variable "ecs_asg_capacity_rebalance" {
  description = "[Optional] Indicates whether capacity rebalance is enabled. Otherwise, capacity rebalance is disabled."
  type        = bool
  default     = false
}


variable "ecs_asg_default_cooldown" {
  description = "[Optional] The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  type        = number
  default     = 300
}



variable "ecs_asg_health_check_grace_period" {
  description = "[Optional] Time (in seconds) after instance comes into service before checking health."
  type        = number
  default     = 300
}


variable "ecs_asg_termination_policies" {
  description = "[Optional] A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, OldestLaunchTemplate, AllocationStrategy, Default."
  type        = list(any)
  default     = []
}


variable "ecs_asg_suspended_processes" {
  description = "[Optional] A list of processes to suspend for the Auto Scaling Group. The allowed values are Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions, AddToLoadBalancer. Note that if you suspend either the Launch or Terminate process types, it can prevent your Auto Scaling Group from functioning properly."
  type        = list(any)
  default     = []
}


variable "ecs_asg_enabled_metrics" {
  description = "[Optional] A list of metrics to collect. The allowed values are GroupDesiredCapacity, GroupInServiceCapacity, GroupPendingCapacity, GroupMinSize, GroupMaxSize, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupStandbyCapacity, GroupTerminatingCapacity, GroupTerminatingInstances, GroupTotalCapacity, GroupTotalInstances."
  type        = list(any)
  default     = []
}


variable "ecs_asg_protect_from_scale_in" {
  description = "[Optional] Allows setting instance protection. The Auto Scaling Group will not select instances with this setting for termination during scale in events."
  type        = bool
  default     = false
}

variable "ecs_asg_override_config" {
  description = "[Optional]  List of nested arguments provides the ability to specify multiple instance types. This will override the same parameter in the launch template. For on-demand instances, Auto Scaling considers the order of preference of instance types to launch based on the order specified in the overrides list."
  type = list(object({
    instance_type     = string
    weighted_capacity = number
  }))
  default = [
    {
      "instance_type" : "m5.2xlarge"
      "weighted_capacity" : 70
    },
    {
      "instance_type" : "c5.2xlarge"
      "weighted_capacity" : 20
    },
    {
      "instance_type" : "r5.2xlarge"
      "weighted_capacity" : 10
    }
  ]
}

variable "import_aws_launch_template" {
  description = "[Optional] True to import an existing aws launch template."
  type        = bool
  default     = false
}

variable "launch_template_id" {
  description = "[Optional] Define if import_aws_launch_template is set to true"
  type        = string
  default     = ""
}

variable "launch_template_name_prefix" {
  description = "[Optional] prefix for launch template of ecs asg"
  type        = string
  default     = "ecs_node_"
}


variable "block_device_mappings" {
  description = "[Optional] In launch configuration configure additional volumes of the instance besides specified by the AMI."
  type = list(object({
    device_name  = string
    no_device    = bool
    virtual_name = string
    ebs = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = number
      kms_key_id            = string
      snapshot_id           = string
      volume_size           = number
      volume_type           = string
    })
  }))

  default = [
  ]
}


variable "kinesis_stream_name" {
  description = "[Optional] prefix for launch template of ecs asg"
  type        = string
  default     = "data-processing-stream"
}