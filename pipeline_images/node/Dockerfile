FROM debian:stretch-slim

RUN apt-get update && apt-get install -y wget curl jq unzip zip python3 gnupg make && \
  curl -O https://bootstrap.pypa.io/get-pip.py && \
  python3 get-pip.py && \
  pip3 install awscli && \
  curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y nodejs
