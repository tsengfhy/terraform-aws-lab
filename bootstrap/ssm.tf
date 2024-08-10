resource "aws_ssm_service_setting" "dhmc" {
  setting_id    = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:servicesetting/ssm/managed-instance/default-ec2-instance-management-role"
  setting_value = join("/", slice(split("/", aws_iam_role.ssm.arn), 1, length(split("/", aws_iam_role.ssm.arn))))
}

resource "aws_iam_role" "ssm" {
  name        = "AWSSystemsManagerDefaultEC2InstanceManagementRole"
  description = "AWS Systems Manager Default EC2 Instance Management Role"
  path        = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.assume["ssm"].json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
  ]

  inline_policy {
    name   = "Logging"
    policy = data.aws_iam_policy_document.ssm.json
  }

  tags = module.context.tags
}

data "aws_iam_policy_document" "ssm" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetEncryptionConfiguration",
    ]
    resources = [
      "${module.log.arn}/*",
      module.log.arn
    ]
  }
}

resource "aws_ssm_document" "session" {
  name          = "SSM-SessionManagerRunShell"
  document_type = "Session"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = module.log.id
      s3KeyPrefix                 = "AWSLogs/${data.aws_caller_identity.current.account_id}/SSM/Session/"
      s3EncryptionEnabled         = false
      cloudWatchLogGroupName      = ""
      cloudWatchEncryptionEnabled = false
      cloudWatchStreamingEnabled  = false
      kmsKeyId                    = ""
      runAsEnabled                = false
      runAsDefaultUser            = ""
      idleSessionTimeout          = "60"
      maxSessionDuration          = "1440"
      shellProfile = {
        windows = ""
        linux   = ""
      }
    }
  })
}