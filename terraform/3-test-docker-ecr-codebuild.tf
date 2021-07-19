#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

module "ecs-docker-codebuild" {
  source   = "./modules/docker-ecr-codebuild"
  tags     = local.common_tags
  prefix_name = "${var.vpc_name}${var.vpc_suffix}"
}