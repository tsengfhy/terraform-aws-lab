resource "aws_key_pair" "default" {
  key_name   = "default"
  public_key = file("${path.module}/certs/default.pub")
}