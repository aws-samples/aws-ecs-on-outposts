#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#
resource "aws_codebuild_project" "ecs_docker" {
  name         = "${var.prefix_name}-${var.tags["Project"]}-ecs-docker-image"
  description  = "codebuild project used to build and push docker images for ecs"
  service_role = aws_iam_role.codebuild.arn
  #encryption_key = data.aws_ssm_parameter.cmk_arn.value
  tags = var.tags

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME_PRODUCER"
      value = var.ecr_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.region.name
    }

    environment_variable {
      name  = "SOURCE_REPO"
      value = "https://github.com/aws-samples/amazon-kinesis-data-processor-aws-fargate"
    }

  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }

  build_timeout = 10

}



resource "aws_iam_role" "codebuild" {
  name               = "${var.tags["Project"]}-codebuild-docker"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.tags["Project"]}-codebuild-docker"
  role = aws_iam_role.codebuild.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ecr",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:PutImage"
      ],
      "Resource": "arn:aws:ecr:${data.aws_region.region.name}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_name}*"
    },
    {
      "Sid": "ecrtoken",
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Sid": "log",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "codebuildreport",
      "Effect": "Allow",
      "Action": [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases"
        ],
      "Resource": "arn:aws:codebuild:${data.aws_region.region.name}:${data.aws_caller_identity.current.account_id}:report-group/*"
    }
  ]
}
EOF
}
