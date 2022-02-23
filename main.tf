resource "aws_iam_role" "integration" {
  name                 = var.role_name
  name_prefix          = var.role_name_prefix
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  path                 = var.path
  tags                 = var.tags
  permissions_boundary = var.permissions_boundary_arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [var.costradar_role_arn]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role_policy" "default" {
  name   = "default-permissions"
  role   = aws_iam_role.integration.id
  policy = data.aws_iam_policy_document.default_permissions.json
}

resource "aws_iam_role_policy" "s3_permissions" {
  count  = length(var.buckets) == 0 ? 0 : 1
  name   = "cur-s3"
  role   = aws_iam_role.integration.id
  policy = data.aws_iam_policy_document.s3_permissions[0].json
}

data "aws_iam_policy_document" "s3_permissions" {
  count = length(var.buckets) == 0 ? 0 : 1
  statement {
    sid     = "S3LogsAndReportsReadOnly"
    actions = ["s3:List*", "s3:Get*"]
    resources = flatten([
      for bucket in var.buckets : ["arn:aws:s3:::${bucket}", "arn:aws:s3:::${bucket}/*"]
    ])
  }
}

data "aws_iam_policy_document" "default_permissions" {
  statement {
    sid = "CloudTrailReadOnly"
    actions = [
      "cloudtrail:ListTrails",
      "cloudtrail:DescribeTrails",
      "cloudtrail:Get*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "CostAndUsageReportReadOnly"
    actions   = ["cur:DescribeReportDefinitions"]
    resources = ["*"]
  }

  statement {
    sid = "CloudWatchAccessReadonly"
    actions = [
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ConfigAccessReadOnly"
    actions = [
      "config:Get*",
      "config:BatchGet*",
      "config:List*",
      "config:Describe*",
      "config:Select*"
    ]
    resources = ["*"]
  }
}