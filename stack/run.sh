#!/usr/bin/env bash

export WORKSPACE=sit

terraform init --backend-config=../backend-config.tfvars
terraform workspace select -or-create $WORKSPACE
terraform plan --var-file=../common.tfvars -lock=false