terraform init -backend-config=../backend-config.tfvars
terraform workspace select $WORKSPACE || terraform workspace new $WORKSPACE
terraform validate -no-color
terraform plan -var-file=../common.tfvars -no-color -out=./terraform.out
terraform apply -no-color ./terraform.out
