@echo off

terraform init --backend-config=backend-config.tfvars
terraform workspace select dev || terraform workspace new dev
terraform plan