#!/bin/bash

aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 849771222433.dkr.ecr.ap-northeast-1.amazonaws.com

docker build --no-cache -t test .
docker tag test:latest 849771222433.dkr.ecr.ap-northeast-1.amazonaws.com/sit-repository-ecs:latest
docker push 849771222433.dkr.ecr.ap-northeast-1.amazonaws.com/sit-repository-ecs:latest