#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

variable "Environment" {
  description = "Environment name used for tagging"
  type        = string
}

variable "Project" {
  description = "project name used for tagging"
  type        = string
}

variable "Owner" {
  description = "owner email address used for tagging"
  type        = string
}

variable "vpc_name" {
  description = "name of the VPC"
  type        = string
}

variable "vpc_suffix" {
  description = "suffix name of the VPC"
  type        = string
}

variable "vpc_main_cidr" {
  description = "main cidr block for VPC"
  type        = string
}

#-----------subnet characteristics

variable "number_AZ" {
  description = "This field is used if you need to create more than one subnet per AZ. Specify the number of AZ's (default 2). In the variable *_subnets_cidr_list, the order should be [CIDR subnet 1 AZ A, CIDR subnet 2 AZ B, CIDR subnet 3 AZ A...]"
  type        = number
  default     = 2
}

variable "private_subnets_cidr_list" {
  description = "A list of private subnet CIDR blocks inside the VPC (for endpoints, eni, etc.)."
  type        = list(string)
  default     = []
}

variable "tgw_subnets_cidr_list" {
  description = "A list of transit gateway private subnets CIDR blocks inside the VPC (for endpoints, eni, etc.)"
  type        = list(string)
  default     = []
}

variable "fw_subnets_cidr_list" {
  description = "A list of network firewall subnets CIDR blocks inside the VPC (for endpoints, eni, etc.)"
  type        = list(string)
  default     = []
}

variable "public_subnets_cidr_list" {
  description = "A list of public subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "web_tier_subnets_cidr_list" {
  description = "A list of web tier subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "pres_tier_subnets_cidr_list" {
  description = "A list of presentation tier subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}


variable "database_tier_subnets_cidr_list" {
  description = "A list of database tier subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "outposts_subnets_cidr_list" {
  description = "A list of outposts subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "outposts_arn" {
  description = "Arn of the outposts where the subnets will be launched"
  type        = string
}

variable "outposts_route_to_LGW_destination" {
  description = "IPv4 CIDR block destination to route to LGW in outposts subnet"
  type        = string
}

variable "outposts_local_gateway_id" {
  description = "Outposts local gateway ID"
  type        = string
}

#------- EC2 instances
variable "ec2_ami_id" {
  description = "ami ID for the EC2 instance to create"
  type        = string
  default     = "ami-00f9f4069d04c0c6e"
}

variable "ec2_instance_type" {
  description = "ami ID for the EC2 instance to create"
  type        = string
  default     = "m5.2xlarge"
}

variable "number_EC2_instances" {
  description = "number EC2 instances to run"
  type        = number
  default     = 1
}

#-------- S3 logging bucket

variable "s3_bucket_outposts_logging_name" {
  description = "name for the S3 bucket in the AWS Region that will be used for logging"
  type        = string
}

variable "alb_access_logs_prefix" {
  description = "[Optional] prefix for the access logs sent to s3 bucket from alb"
  type        = string
  default     = "alb"
}

#-------- Kinesis
variable "kinesis_stream_name" {
  description = "[Optional] prefix for launch template of ecs asg"
  type        = string
}