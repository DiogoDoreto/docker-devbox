FROM ubuntu

MAINTAINER Diogo Doreto <diogo.doreto@gmail.com>

# CONFIG
ENV NODE_VERSION 0.12.5
ENV GO_VERSION 1.4.2

# apt-get install
RUN apt-get update && apt-get install -y \
        cmake \
        curl \
        g++ \
        git \
        make \
        man-db \
        mercurial \
        procps \
        python-dev \
        python-pip \
        ruby-full \
        ssh \
        tmux \
        unzip \
        vim \
        wget \
        zsh \
        --no-install-recommends \
        && rm -rf /var/lib/apt/lists/*

# Install NodeJS
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
        && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
        && gpg --verify SHASUMS256.txt.asc \
        && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
        && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
        && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
        && npm install -g npm \
        && npm cache clear

# Install go
RUN curl https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar -C /usr/local -zx
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH
RUN mkdir -p /go/src
VOLUME /go/src

# Install Exuberant ctags
RUN curl -L http://downloads.sourceforge.net/project/ctags/ctags/5.8/ctags-5.8.tar.gz | tar -C /usr/local -zx \
        && cd /usr/local/ctags-5.8 && ./configure && make && make install

# Change timezone
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# dotfiles
ADD dotfiles /root/.dotfiles
RUN /root/.dotfiles/script/install
RUN echo 'Diogo Doreto\ndiogo.doreto@gmail.com' | /root/.dotfiles/script/bootstrap

# Vundle install plugins
RUN vim +PluginInstall +qall
RUN vim +GoInstallBinaries +qall


WORKDIR /go/src
CMD /bin/zsh
