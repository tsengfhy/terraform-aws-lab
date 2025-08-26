output "arn" {
  value = aws_sfn_state_machine.this.arn
}

output "state_machine_version_arn" {
  value = aws_sfn_state_machine.this.state_machine_version_arn
}