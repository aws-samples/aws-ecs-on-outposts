#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#
module "producer-outposts-ecs-alb" {
  depends_on = [module.ecs-docker-codebuild, aws_s3_bucket.s3_bucket_outposts_logging]

  source   = "./modules/alb-ecs"
  tags     = local.common_tags
  vpc_name = "${var.vpc_name}${var.vpc_suffix}"

  alb_name = "ALB-ECS"
  subnets  = [module.test-vpc.subnet_outposts_ids[0]]

  enable_alb_access_logging = true
  logging_bucket_name       = aws_s3_bucket.s3_bucket_outposts_logging.id
  alb_access_logs_prefix    = var.alb_access_logs_prefix

  port_listeners = {
    "port-1" = {
      "port"               = 80,
      "protocol"           = "HTTP",
      "inbound_cidr_range" = [var.vpc_main_cidr]
      "target_group" = {
        "port"              = 8080,
        "protocol"          = "HTTP",
        "health_check_path" = "/healthcheck"
      }
    }
  }

  outposts_arn       = var.outposts_arn
  ecs_cluster_name   = "producer-cluster"
  log_group_name     = "producer-log"
  log_retention_days = 30
  ecr_name           = "kinesis/producer"

  ec2_iam_instance_profile = module.test-vpc.iam_instance_profile_ec2_ssm_id

}



