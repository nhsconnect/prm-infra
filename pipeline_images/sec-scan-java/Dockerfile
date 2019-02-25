FROM java:openjdk-9

RUN apt-get update && apt-get install -y zip unzip gnupg && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs npm  && \
    node -v && \
    npm -v && \
    npm i -g recursive-install
    
