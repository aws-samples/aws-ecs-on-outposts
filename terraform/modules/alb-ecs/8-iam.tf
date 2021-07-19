#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

################
# FARGATE IAM ROLES
################

resource "aws_iam_role" "ecs_execution_role" {
  count              = var.import_aws_ecs_task_definition ? 0 : 1
  name               = "${var.tags["Project"]}-${var.ecs_cluster_name}-execution"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_managed_policy" {
  count      = var.import_aws_ecs_task_definition ? 0 : 1
  role       = aws_iam_role.ecs_execution_role[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  count = var.import_aws_ecs_task_definition ? 0 : 1
  name  = "${var.tags["Project"]}-${var.ecs_cluster_name}-task"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": 
        [
            "ecs-tasks.amazonaws.com",
            "ecs.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  count = var.import_aws_ecs_task_definition ? 0 : 1
  name  = "${var.tags["Project"]}-ecs-task-policy"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "taskrole1",
      "Effect": "Allow",
      "Action": [
        "kinesis:ListStreams",
        "kinesis:ListShards",
        "kinesis:PutRecords",
        "kinesis:PutRecord"
      ],
      "Resource": "*"
    },
    {
      "Sid": "taskrole2",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "taskrole3",
      "Effect": "Allow",
      "Action": "cloudwatch:PutMetricData",
      "Resource": "*"
    }
  ]
}
EOF
}
