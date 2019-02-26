FROM owasp/dependency-check:4.0.2

USER root

RUN apt-get update && apt-get install -y wget curl gnupg unzip jq && \
  curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y nodejs && \
  npm i -g recursive-install
