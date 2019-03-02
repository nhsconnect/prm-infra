FROM debian:stretch-slim

RUN apt-get update && apt-get install -y wget jq unzip python2.7 python3 curl make && \
  ln -s $(which python2.7) /usr/bin/python && \
  wget -q https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip && \
  unzip terraform_0.11.10_linux_amd64.zip -d /bin && \
  chmod +x /bin/terraform && \
  rm terraform_0.11.10_linux_amd64.zip && \
  wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.17.3/terragrunt_linux_amd64 -O /bin/terragrunt && \
  chmod +x /bin/terragrunt && \
  curl -O https://bootstrap.pypa.io/get-pip.py && \
  python3 get-pip.py && \
  pip3 install awscli