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

resource "aws_iam_role_policy" "cur_s3" {
  count  = var.cur == null ? 0 : 1
  name   = "cur-s3"
  role   = aws_iam_role.integration.id
  policy = data.aws_iam_policy_document.cur_s3_permissions[0].json
}

resource "aws_iam_role_policy" "cloudtrail_s3" {
  count  = var.cloudtrail == null ? 0 : 1
  name   = "cloudtrail-s3"
  role   = aws_iam_role.integration.id
  policy = data.aws_iam_policy_document.cloudtrail_s3_permissions[0].json
}

data "aws_iam_policy_document" "cur_s3_permissions" {
  count = var.cur == null ? 0 : 1
  statement {
    sid     = "S3LogsAndReportsReadOnly"
    actions = ["s3:List*", "s3:Get*"]
    resources = [
      "arn:aws:s3:::${var.cur.bucket}",
      "arn:aws:s3:::${var.cur.bucket}/*",
    ]
  }
}

data "aws_iam_policy_document" "cloudtrail_s3_permissions" {
  count = var.cloudtrail == null ? 0 : 1
  statement {
    sid     = "S3LogsAndReportsReadOnly"
    actions = ["s3:List*", "s3:Get*"]
    resources = [
      "arn:aws:s3:::${var.cloudtrail.bucket}",
      "arn:aws:s3:::${var.cloudtrail.bucket}/*",
    ]
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