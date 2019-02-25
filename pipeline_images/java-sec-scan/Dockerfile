FROM java:openjdk-9

RUN apt-get update && apt-get install -y zip unzip gnupg && \
    git clone https://github.com/creationix/nvm.git; cd nvm && \
    ./install.sh; export NVM_DIR="$HOME/.nvm"; \. "$NVM_DIR/nvm.sh" && \
    chmod a+x $HOME/.nvm/nvm.sh; export PATH=$PATH:/$HOME/.nvm && \
    . $NVM_DIR/nvm.sh && nvm install 8 npm && \
    node -v && \
    npm -v && \
    npm i -g recursive-install
    
