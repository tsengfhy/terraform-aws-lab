resource "aws_iam_role" "ecs_task_execution" {
  name = "ServiceRoleECSTaskExecution"

  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess",
  ]

  inline_policy {
    name   = "SecretsManagerReadOnly"
    policy = data.aws_iam_policy_document.secrets_manager_read_only.json
  }
}

resource "aws_iam_role" "ecs_task" {
  name = "ServiceRoleECSTask"

  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role" "batch" {
  name = "ServiceRoleBatch"

  assume_role_policy = data.aws_iam_policy_document.batch_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole",
  ]
}

resource "aws_iam_role" "event_target_batch" {
  name = "ServiceRoleEventTargetBatch"

  assume_role_policy = data.aws_iam_policy_document.events_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBatchServiceEventTargetRole",
  ]
}