FROM debian:stretch-slim

RUN apt-get update && apt-get install -y curl git python3 && \
  curl -O https://bootstrap.pypa.io/get-pip.py && \
  python3 get-pip.py && \
  pip install truffleHog && \
  pip install detect-secrets && \
  curl -Lo git-secrets.tgz https://github.com/awslabs/git-secrets/archive/1.3.0.tar.gz && \
  tar zxf git-secrets.tgz && \
  cp git-secrets-1.3.0/git-secrets /usr/local/bin && \
  chmod +x /usr/local/bin/git-secrets && \
  rm -rf git-secrets-1.3.0 git-secrets.tgz get-pip.py
