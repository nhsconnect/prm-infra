FROM debian:stretch-slim

RUN apt-get update && apt-get install -y wget jq unzip zip nodejs npm python3 && \
  curl -O https://bootstrap.pypa.io/get-pip.py && \
  python3 get-pip.py && \
  pip3 install awscli
