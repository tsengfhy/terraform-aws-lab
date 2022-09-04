FROM mcr.microsoft.com/vscode/devcontainers/universal:2-focal

USER root

ARG TERRAFORM_VERSION=1.1.9
RUN curl -L -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv -f terraform /usr/local/bin/

RUN apt-get update && apt-get -y install awscli

USER codespace
