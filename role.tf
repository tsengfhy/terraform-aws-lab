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