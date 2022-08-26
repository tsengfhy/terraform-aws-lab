#!/bin/bash

workspace=global

terraform init -backend-config=../backend-config.tfvars
terraform workspace select $workspace || terraform workspace new $workspace
terraform plan -var-file=../common.tfvars