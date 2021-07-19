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

variable "prefix_name" {
  type        = string
  description = "prefix for resources"
}

variable "ecr_name" {
  description = "[Optional] name for ECR"
  type        = string
  default     = "kinesis/producer"
}

