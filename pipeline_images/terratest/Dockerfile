FROM debian:stretch-slim

RUN apt-get update && apt-get install -y wget jq unzip python2.7 python3 curl make && \
  ln -s $(which python2.7) /usr/bin/python && \
  wget -q https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip && \
  unzip terraform_0.11.10_linux_amd64.zip -d /bin && \
  chmod +x /bin/terraform && \
  rm terraform_0.11.10_linux_amd64.zip && \
  curl -O https://bootstrap.pypa.io/get-pip.py && \
  python3 get-pip.py && \
  pip3 install awscli && \
  curl -O https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz && \
  tar -C /usr/local -xzf go1.11.5.linux-amd64.tar.gz && \
  ln -s /usr/local/go/bin/go /usr/bin/go && \
  mkdir -p /root/go/bin && \
  curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

  ENV PATH=/root/go/bin:${PATH}