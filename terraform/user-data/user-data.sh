#!/bin/bash
#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

sudo yum install -y https://s3.${Region}.amazonaws.com/amazon-ssm-${Region}/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl status amazon-ssm-agent

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl status amazon-ssm-agent